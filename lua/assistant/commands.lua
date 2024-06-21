local ui = require("assistant.ui")

local M = {}

function M.load()
  vim.api.nvim_create_user_command("AssistantToggle", ui.toggle_window, {})
end

return M
