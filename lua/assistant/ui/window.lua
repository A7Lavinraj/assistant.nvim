local state = require("assistant.state")
local utils = require("assistant.ui.utils")

local AssistantWindow = {}

function AssistantWindow.new()
  local self = setmetatable({}, { __index = AssistantWindow })
  self.buf = nil
  self.win = nil
  self.is_open = false
  self.height = 0.8
  self.width = 0.6
  self.augroup = vim.api.nvim_create_augroup("AssistantWindow", { clear = true })
  self.state = state.new()

  return self
end

function AssistantWindow:float_opts()
  return {
    relative = "editor",
    width = utils.size(vim.o.columns, self.width),
    height = utils.size(vim.o.lines, self.height),
    row = math.floor((vim.o.lines - utils.size(vim.o.lines, self.height)) / 2),
    col = math.floor((vim.o.columns - utils.size(vim.o.columns, self.width)) / 2),
    style = "minimal",
  }
end

function AssistantWindow:buf_valid()
  return vim.api.nvim_buf_is_valid(self.buf)
end

function AssistantWindow:win_valid()
  return vim.api.nvim_win_is_valid(self.win)
end

function AssistantWindow:clear_window(from, to)
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })
  vim.api.nvim_buf_set_lines(self.buf, from, to, false, {})
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
end

function AssistantWindow:create_window()
  if self.is_open then
    return
  end

  self.buf = vim.api.nvim_create_buf(false, true)
  self.win = vim.api.nvim_open_win(self.buf, true, self:float_opts())
  self.is_open = true

  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })

  vim.api.nvim_create_autocmd("VimResized", {
    group = self.augroup,
    callback = function()
      if self:win_valid() then
        vim.api.nvim_win_set_config(self.win, self:float_opts())
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, {
    group = self.augroup,
    buffer = self.buf,
    callback = function()
      self:delete_window()
    end,
  })
end

function AssistantWindow:delete_window()
  if not self.is_open then
    return
  end

  vim.schedule(function()
    if self:win_valid() then
      vim.api.nvim_win_close(self.win, true)
      self.win = -1
    end

    if self:buf_valid() then
      vim.api.nvim_buf_delete(self.buf, { force = true })
      self.buf = -1
    end
  end)

  self.is_open = false
end

return AssistantWindow
