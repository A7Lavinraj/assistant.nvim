local utils = require("assistant.utils")

---@class AssistantWindow
local AssistantWindow = {}

---@param opts AssistantWindow.Opts
function AssistantWindow.new(opts)
  return setmetatable(opts, { __index = AssistantWindow })
end

---@return table
function AssistantWindow:conf()
  return vim.tbl_deep_extend("force", self.config, {
    height = utils.height(self.h_ratio),
    width = utils.width(self.w_ratio),
    row = utils.row(self.h_ratio, self.v_align),
    col = utils.col(self.w_ratio, self.h_align),
  })
end

---@param opts table?
function AssistantWindow:wo(opts)
  for opt, val in pairs(opts or {}) do
    vim.api.nvim_set_option_value(opt, val, { win = self.win })
  end
end

---@param opts table?
function AssistantWindow:bo(opts)
  for opt, val in pairs(opts or {}) do
    vim.api.nvim_set_option_value(opt, val, { buf = self.buf })
  end
end

---@return boolean
function AssistantWindow:is_buf()
  if not self.buf then
    return false
  end

  return vim.api.nvim_buf_is_valid(self.buf)
end

function AssistantWindow:is_win()
  if not self.win then
    return false
  end

  return vim.api.nvim_win_is_valid(self.win)
end

function AssistantWindow:on_key(mode, lhs, rhs)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = self.buf })
end

function AssistantWindow:resize()
  if not self:is_win() then
    return
  end

  vim.api.nvim_win_set_config(self.win, self:conf())
end

function AssistantWindow:create()
  if not self.is_open then
    self.buf = vim.api.nvim_create_buf(false, true)
    self.win = vim.api.nvim_open_win(self.buf, self.enter, self:conf())
    self:wo(self.win_opts)
    self:bo(self.buf_opts)
    self.is_open = true
  end
end

function AssistantWindow:remove()
  if self.is_open then
    if self:is_win() then
      vim.api.nvim_win_close(self.win, true)
      self.win = nil
    end

    if self:is_buf() then
      vim.api.nvim_buf_delete(self.buf, { force = true })
      self.buf = nil
    end

    self.is_open = false
  end
end

function AssistantWindow:toggle()
  if self.is_open then
    self:remove()
  else
    self:create()
  end
end

return AssistantWindow
