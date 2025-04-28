local Window = require 'assistant.lib.window'

---@class Assistant.Previewer.Options
---@field canvas Assistant.Canvas

---@class Assistant.Previewer : Assistant.Previewer.Options
---@field window Assistant.Window
local Previewer = {}

---@param options? Assistant.Previewer.Options
function Previewer.new(options)
  return setmetatable({}, { __index = Previewer }):init(options)
end

---@param options? Assistant.Previewer.Options
function Previewer:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end
  self.window = Window.new {}
  return self
end

---@param test_ID integer
function Previewer:preview(test_ID)
  self.canvas:set(self.window.bufnr, require('assistant.state').get_global_key('tests')[test_ID])
end

return Previewer
