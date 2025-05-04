---@alias Assistant.Processor.Command { main?: string, args?: string[] }

---@class Assistant.Process.Options
---@field _co thread

---@class Assistant.Process : Assistant.Process.Options
local Process = {}

---@param options Assistant.Process.Options
---@return Assistant.Process
function Process.new(options)
  return setmetatable({}, {
    __index = Process,
  }):init(options)
end

---@param options Assistant.Process.Options
---@return Assistant.Process
function Process:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  return self
end

---@param fn function
function Process:spawn(fn)
  if not self:is_suspended() then
    return
  end

  coroutine.resume(self._co)
  self:on_dead(fn)
end

---@param fn function
function Process:on_dead(fn)
  if coroutine.status(self._co) == 'dead' then
    fn()
    return
  end

  vim.defer_fn(function()
    self:on_dead(fn)
  end, 10)
end

---@return boolean
function Process:is_suspended()
  return coroutine.status(self._co) == 'suspended'
end

return Process
