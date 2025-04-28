---@class Assistant.Queue
---@field private arr any[]
local Queue = {}

function Queue.new()
  return setmetatable({ arr = {} }, { __index = Queue })
end

---@param element any
function Queue:push(element)
  table.insert(self.arr, element)
end

---@return any
function Queue:pop()
  assert(#self.arr, 'cannot pop element from empty queue')
  return table.remove(self.arr, 1)
end

---@return any
function Queue:top()
  assert(#self.arr, 'cannot return top element from empty queue')
  return self.arr[1]
end

---@return boolean
function Queue:empty()
  return #self.arr == 0
end

---@return integer
function Queue:size()
  return #self.arr
end

return Queue
