local ui = require("assistant.ui")
local M = {}

function M.load()
  vim.keymap.set("n", "<TAB>", ui.move, { desc = "Move in floats" })
end

function M.unload()
  vim.keymap.del("n", "1")
  vim.keymap.del("n", "2")
  vim.keymap.del("n", "3")
  vim.keymap.del("n", "4")
end

return M
