local State = require("assistant.ui.state")
local Window = require("assistant.ui.window")
local config = require("assistant.config")
local renderer = require("assistant.ui.renderer")
local store = require("assistant.store")
local transformer = require("assistant.ui.transformer")

local M = setmetatable({ access = false }, {
  __index = Window.new(State.new({
    relative = "editor",
    style = "minimal",
    width = 0.5,
    height = 0.7,
    border = config.border,
  })),
})

function M:render_tab()
  if store.TAB == 1 then
    renderer.render(self.state.buf, self.access, transformer.merge(transformer.tabs(), transformer.problem()))
  elseif store.TAB == 2 then
    renderer.render(self.state.buf, self.access, transformer.merge(transformer.tabs(), transformer.testcases()))
  end
end

return M
