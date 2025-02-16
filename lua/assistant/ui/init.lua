local AstLayout = require("assistant.ui.layout")
local AstText = require("assistant.ui.text")
local state = require("assistant.state")
local utils = require("assistant.utils")

local M = AstLayout.new({
  width = 0.8,
  height = 0.8,
  pane_config = {
    root = {
      width = 0.4,
      height = 1,
      dheight = -3,
      title = "Tasks",
      title_pos = "center",
      enter = true,
    },
    actions = {
      dheight = 1,
      width = 0.4,
      bottom = "root",
      title = "Actions",
      title_pos = "center",
    },
    logs = {
      width = 0.6,
      height = 1,
      right = "root",
      title = "Logs",
      title_pos = "center",
    },
  },
})

function M:_init()
  state.update_all()

  local text = AstText.new()

  text:append("Hello from Assistant.nvim", "IncSearch")
  self:show()

  utils.render(self.pane_config["root"].buf, text)
end

return M
