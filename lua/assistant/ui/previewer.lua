local Window = require("assistant.ui.window")
local config = require("assistant.config")
local rend = require("assistant.ui.renderer")
local tran = require("assistant.ui.transformer")
local M = Window.new({
  h_ratio = 0.7,
  w_ratio = 0.3,
  h_align = "end",
  v_align = "center",
  enter = false,
  access = false,
  config = {
    relative = "editor",
    style = "minimal",
    border = config.border,
  },
  win_opts = {
    winhighlight = "NormalFloat:AssistantWindow,FloatBorder:AssistantWindowBorder",
  },
})

---@param tc_number number | nil
function M:preview(tc_number)
  rend(self.state.buf, self.access, tran.testcase(tc_number, M.state.win))
end

return M
