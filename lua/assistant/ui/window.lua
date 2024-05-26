local Buttonset = require("assistant.ui.buttonset")
local Renderer = require("assistant.ui.renderer")
local Runner = require("assistant.runner")
local State = require("assistant.state")
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
  self.state = State.new()
  self.renderer = Renderer.new()
  self.runner = Runner.new()
  self.buttonset = Buttonset.new()
  self.runner = Runner.new()

  return self
end

function AssistantWindow:init()
  self.state:init()
  self.renderer:init(self.buf)
  self.buttonset:init({
    {
      text = " 󰟍 Assistant.nvim ",
      group = "AssistantButtonActive",
      is_active = true,
    },
    {
      text = "  Run Test ",
      group = "AssistantButton",
      is_active = false,
    },
  })
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

  self.buf = vim.api.nvim_create_buf(false, true)
  self:init()
  self.win = vim.api.nvim_open_win(self.buf, true, self:float_opts())
  self.is_open = true
  self.cpos = vim.api.nvim_win_get_cursor(self.win)

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
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = self.augroup,
    buffer = self.buf,
    callback = function()
      self.cpos = vim.api.nvim_win_get_cursor(self.win)
    end,
  })
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
