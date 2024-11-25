local M = {}

---@type {mode:string,lhs:string,rhs:string|function,buf:number}[]
M.keys = {}

---@param mode string
---@param lhs string
---@param rhs string|function
---@param buf number
function M.set(mode, lhs, rhs, buf)
  vim.keymap.set(mode, lhs, rhs, { buffer = buf })
  table.insert(M.keys, {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    buf = buf,
  })
end

---@param mode string
---@param lhs string
---@param buf number
function M.clear(mode, lhs, buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  vim.keymap.del(mode, lhs, { buffer = buf })
  local id = 0

  for i = 1, #M.keys do
    if M.keys[i].mode == mode and M.keys[i].lhs == lhs and M.keys[i].buf == buf then
      id = i
      break
    end
  end

  if id == 0 then
    return
  end

  table.remove(M.keys, id)
end

function M.clear_all()
  for _, key in ipairs(M.keys) do
    M.clear(key.mode, key.lhs, key.buf)
  end
end

return M
