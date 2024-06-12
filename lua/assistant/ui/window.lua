local State = require("assistant.state")
local defaults = require("assistant.defaults")
local utils = require("assistant.utils")

---@class AssistantWindow
local AssistantWindow = {}

function AssistantWindow.new()
  local self = setmetatable({}, { __index = AssistantWindow })

  self.buf = nil
  self.win = nil
  self.is_open = false
  self.augroup = vim.api.nvim_create_augroup("AssistantWindow", { clear = true })
  self.opts = defaults.win_opts
  self.state = State.new()

  return self
end

function AssistantWindow:update_opts(opts)
  if not self:win_valid() then
    return
  end

  vim.api.nvim_win_set_config(self.win, vim.tbl_deep_extend("force", self.opts, opts))
end

function AssistantWindow:resize()
  self:update_opts({
    width = utils.size(vim.o.columns, self.opts.width),
    height = utils.size(vim.o.lines, self.opts.height),
    row = math.floor((vim.o.lines - utils.size(vim.o.lines, self.opts.height)) / 2),
    col = math.floor((vim.o.columns - utils.size(vim.o.columns, self.opts.width)) / 2),
  })
end

function AssistantWindow:buf_valid()
  if self.buf == nil then
    return false
  end

  return vim.api.nvim_buf_is_valid(self.buf)
end

function AssistantWindow:win_valid()
  if self.win == nil then
    return false
  end

  return self.win and vim.api.nvim_win_is_valid(self.win)
end

function AssistantWindow:create_window()
  if self.is_open then
    return
  end

  self.is_open = true
  self.state:init()
  self.buf = vim.api.nvim_create_buf(false, true)
  self.win = vim.api.nvim_open_win(self.buf, true, {
    relative = "editor",
    style = "minimal",
    width = utils.size(vim.o.columns, self.opts.width),
    height = utils.size(vim.o.lines, self.opts.height),
    row = math.floor((vim.o.lines - utils.size(vim.o.lines, self.opts.height)) / 2),
    col = math.floor((vim.o.columns - utils.size(vim.o.columns, self.opts.width)) / 2),
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = self.augroup,
    callback = function()
      self:resize()
    end,
  })
  vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, {
    group = self.augroup,
    buffer = self.buf,
    callback = function()
      self:delete_window()
    end,
  })

  vim.cmd("doautocmd User AssistantTabRender")
  vim.cmd("doautocmd User AssistantWindowCreate")

  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
end

function AssistantWindow:delete_window()
  if self.is_open == false then
    return
  end

  if self:buf_valid() then
    vim.api.nvim_buf_delete(self.buf, { force = true })
    self.buf = nil
  end

  if self:win_valid() then
    vim.api.nvim_win_close(self.win, true)
    self.win = nil
  end

  self.is_open = false
end

return AssistantWindow
