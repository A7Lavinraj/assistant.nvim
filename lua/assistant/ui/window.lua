local config = require("assistant.config")
local emitter = require("assistant.emitter")
local utils = require("assistant.utils")

---@class AssistantWindow
local AssistantWindow = {}

---@param state AssistantWindowState
---@return AssistantWindow
function AssistantWindow.new(state)
  return setmetatable({ state = state }, { __index = AssistantWindow })
end

function AssistantWindow.opts(custom)
  local opts = {}
  opts.relative = "editor"
  opts.style = "minimal"
  opts.width = utils.width(0.5)
  opts.height = utils.height(0.7)
  opts.row = utils.row(0.7)
  opts.col = utils.col(0.5)
  opts.border = config.border

  vim.tbl_deep_extend("force", opts, custom or {})

  return opts
end

function AssistantWindow:create()
  if not self.state.is_open then
    self.state.buf = vim.api.nvim_create_buf(false, true)
    self.state.win =
      vim.api.nvim_open_win(self.state.buf, true, self.state:get_config())
    self.state.is_open = true

    vim.api.nvim_set_option_value(
      "winhighlight",
      "Normal:AssistantNormal",
      { win = self.state.win }
    )
    emitter.emit("AssistantOpenWindow")
    emitter.emit("AssistantRender")
  end
end

function AssistantWindow:remove()
  if self.state.is_open then
    if self:is_win() then
      vim.api.nvim_win_close(self.state.win, true)
      self.state.win = nil
    end

    if self:is_buf() then
      vim.api.nvim_buf_delete(self.state.buf, { force = true })
      self.state.buf = nil
    end

    self.state.is_open = false
  end
end

function AssistantWindow:toggle()
  if self.state.is_open then
    self:remove()
  else
    self:create()
  end
end

function AssistantWindow:resize()
  if not self:is_win() then
    return
  end

  vim.api.nvim_win_set_config(self.state.win, self.state:get_config())
end

---@param mode string
---@param lhs string
---@param rhs string | function
function AssistantWindow:on_key(mode, lhs, rhs)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = self.state.buf })
end

---@return boolean
function AssistantWindow:is_buf()
  if not self.state.buf then
    return false
  end

  return vim.api.nvim_buf_is_valid(self.state.buf)
end

---@return boolean
function AssistantWindow:is_win()
  if not self.state.win then
    return false
  end

  return vim.api.nvim_win_is_valid(self.state.win)
end

return AssistantWindow
