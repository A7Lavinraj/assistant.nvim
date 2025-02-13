---@class AssistantFloat
local AssistantFloat = {}

---@return AssistantFloat
function AssistantFloat.new()
  return setmetatable({}, { __index = AssistantFloat })
end

---@param key string
---@param value any
function AssistantFloat:wo(key, value)
  vim.api.nvim_set_option_value(key, value, { win = self.win })
end

---@param key string
---@param value any
function AssistantFloat:bo(key, value)
  vim.api.nvim_set_option_value(key, value, { buf = self.buf })
end

---@return boolean
function AssistantFloat:is_buf()
  if not self.buf then
    return false
  end

  return vim.api.nvim_buf_is_valid(self.buf)
end

---@return boolean
function AssistantFloat:is_win()
  if not self.win then
    return false
  end

  return vim.api.nvim_win_is_valid(self.win)
end

---@param mode string
---@param lhs string
---@param rhs any
function AssistantFloat:on_key(mode, lhs, rhs)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = self.buf })
end

function AssistantFloat:create()
  if not self.is_open then
    self.buf = vim.api.nvim_create_buf(false, true)
    self.win = vim.api.nvim_open_win(self.buf, self.enter, self.conf)
    self.is_open = true
  end
end

function AssistantFloat:remove()
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

function AssistantFloat:toggle()
  if self.is_open then
    self:remove()
  else
    self:create()
  end
end

return AssistantFloat
