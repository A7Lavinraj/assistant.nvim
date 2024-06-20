local loader = require("assistant.loader")
local ui = require("assistant.ui")

local M = {}

function M.setup(opts)
  loader.add_list({ { name = "config", opts = opts }, { name = "observers" }, { name = "server" } })
  loader.load()

  vim.api.nvim_create_user_command("AssistantToggle", ui.toggle_window, { desc = "Toggle assistant window" })
end

return M
