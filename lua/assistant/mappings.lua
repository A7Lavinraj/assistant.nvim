local ui = require("assistant.ui")

local M = {}

function M.load()
  ui.on_key("n", "q", ui.close_window)
end

return M
