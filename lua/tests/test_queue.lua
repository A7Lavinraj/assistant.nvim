local Queue = require 'assistant.algos.queue'
local test = require 'mini.test'
local T = test.new_set()

T['new() creates an empty queue'] = function()
  local q = Queue.new()
  test.expect.equality(q:empty(), true)
  test.expect.equality(q:size(), 0)
end

T['push() adds elements to the queue'] = function()
  local q = Queue.new()
  q:push(10)
  q:push(20)
  test.expect.equality(q:size(), 2)
  test.expect.equality(q:top(), 10)
end

T['pop() removes elements in FIFO order'] = function()
  local q = Queue.new()
  q:push 'a'
  q:push 'b'
  test.expect.equality(q:pop(), 'a')
  test.expect.equality(q:pop(), 'b')
  test.expect.equality(q:empty(), true)
end

T['top() returns the first element without removing it'] = function()
  local q = Queue.new()
  q:push 'x'
  test.expect.equality(q:top(), 'x')
  test.expect.equality(q:size(), 1)
end

return T
