---@class Assistant.Queue
---@field private arr any[]
local M = {}

function M.new()
  return setmetatable({ arr = {} }, { __index = M })
end

---@param element any
function M:push(element)
  table.insert(self.arr, element)
end

---@return any
function M:pop()
  assert(#self.arr, 'cannot pop element from empty queue')
  return table.remove(self.arr, 1)
end

---@return any
function M:top()
  assert(#self.arr, 'cannot return top element from empty queue')
  return self.arr[1]
end

---@return boolean
function M:empty()
  return #self.arr == 0
end

---@return integer
function M:size()
  return #self.arr
end

return M
