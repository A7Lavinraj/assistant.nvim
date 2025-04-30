---@class Assistant.Panel.Options
---@field canvas Assistant.Canvas

---@class Assistant.Panel : Assistant.Panel.Options
local Panel = {}

---@param options Assistant.Panel.Options
function Panel.new(options)
  return setmetatable({}, {
    __index = Panel,
  }):init(options)
end

---@param options Assistant.Panel.Options
function Panel:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  return self
end

return Panel
