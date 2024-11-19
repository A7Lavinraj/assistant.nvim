---@class AssistantFloat
local AssistantFloat = {}

---@return AssistantFloat
function AssistantFloat.new()
  return setmetatable({}, { __index = AssistantFloat })
end

---@param opts AssistantFloat.opts
function AssistantFloat:init(opts)
  self.enter = opts.enter or self.enter
  self.bopts = opts.bopts or self.bopts
  self.wopts = opts.wopts or self.wopts
  self.conf = opts.conf or self.conf
end

---@param opts table?
function AssistantFloat:wo(opts)
  for opt, val in pairs(opts or {}) do
    vim.api.nvim_set_option_value(opt, val, { win = self.win })
  end
end

---@param opts table?
function AssistantFloat:bo(opts)
  for opt, val in pairs(opts or {}) do
    vim.api.nvim_set_option_value(opt, val, { buf = self.buf })
  end
end

---@return boolean
function AssistantFloat:is_buf()
  if not self.buf then
    return false
  end

  return vim.api.nvim_buf_is_valid(self.buf)
end

function AssistantFloat:is_win()
  if not self.win then
    return false
  end

  return vim.api.nvim_win_is_valid(self.win)
end

function AssistantFloat:on_key(mode, lhs, rhs)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = self.buf })
end

function AssistantFloat:create()
  if not self.is_open then
    self.buf = vim.api.nvim_create_buf(false, true)
    self.win = vim.api.nvim_open_win(self.buf, self.enter, self.conf)
    self:wo(self.wopts)
    self:bo(self.bopts)
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
