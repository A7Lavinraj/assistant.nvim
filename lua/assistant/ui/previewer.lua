local State = require("assistant.ui.state")
local Window = require("assistant.ui.window")
local renderer = require("assistant.ui.renderer")
local transformer = require("assistant.ui.transformer")

local M = setmetatable({ access = false }, {
  __index = Window.new(
    State.new({
      relative = "editor",
      height = 0.7,
      width = 0.3,
      row = "center",
      col = "end",
      style = "minimal",
      border = "single",
      zindex = 99,
    }),
    function(_, win)
      vim.api.nvim_set_option_value(
        "winhighlight",
        "NormalFloat:AssistantPrompt,FloatBorder:AssistantPromptBorder",
        { win = win }
      )
    end
  ),
})

---@param tc_number number | nil
function M:preview(tc_number)
  renderer.render(self.state.buf, self.access, transformer.testcase(tc_number, M.state.win))
end

return M
