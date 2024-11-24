local ui = require("assistant.ui")
local M = {}

function M.load()
  vim.keymap.set("n", "<TAB>", ui.move, { desc = "Move in floats" })
end

function M.unload()
  vim.keymap.del("n", "<TAB>")
end

return M
