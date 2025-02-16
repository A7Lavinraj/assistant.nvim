local AstLayout = require("assistant.ui.layout")
local AstText = require("assistant.ui.text")
local state = require("assistant.state")
local utils = require("assistant.utils")
local opt = require("assistant.config").opts

local M = AstLayout.new({
  width = opt.ui.width,
  height = opt.ui.height,
  pane_config = {
    root = {
      width = 0.4,
      height = 1,
      dheight = -3,
      title = "Tasks " .. opt.ui.tasks.title_icon,
      enter = true,
    },
    actions = {
      dheight = 1,
      width = 0.4,
      bottom = "root",
      title = "Actions " .. opt.ui.tasks.title_icon,
    },
    logs = {
      width = 0.6,
      height = 1,
      right = "root",
      title = "Logs " .. opt.ui.tasks.title_icon,
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
