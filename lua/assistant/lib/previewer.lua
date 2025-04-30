---@class Assistant.Previewer.Options
---@field canvas Assistant.Canvas
---@field width number

---@class Assistant.Previewer : Assistant.Previewer.Options
local Previewer = {}

---@param options? Assistant.Previewer.Options
function Previewer.new(options)
  return setmetatable({}, {
    __index = Previewer,
  }):init(options)
end

---@param options? Assistant.Previewer.Options
function Previewer:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  return self
end

return Previewer
