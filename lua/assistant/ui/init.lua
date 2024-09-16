local State = require("assistant.ui.state")
local Window = require("assistant.ui.window")
local config = require("assistant.config")
local previewer = require("assistant.ui.previewer")
local renderer = require("assistant.ui.renderer")
local transformer = require("assistant.ui.transformer")

local M = setmetatable({ access = false }, {
  __index = Window.new(
    State.new({
      relative = "editor",
      style = "minimal",
      width = 0.6,
      height = 0.7,
      row = "center",
      col = "center",
      border = config.border,
    }),
    function(_, win)
      vim.api.nvim_set_option_value(
        "winhighlight",
        "NormalFloat:AssistantWindow,FloatBorder:AssistantWindowBorder",
        { win = win }
      )
    end
  ),
})

function M:render()
  previewer:create(false)
  renderer.render(self.state.buf, self.access, transformer.merge(transformer.header(), transformer.tests_list()))
end

return M
