local config = require("assistant.config")
local observers = require("assistant.observers")
local server = require("assistant.server")
local ui = require("assistant.ui")

local M = {}

function M.setup(opts)
  config.load(opts)
  server.load()
  observers.load()
  vim.api.nvim_create_user_command("AssistantToggle", ui.toggle_window, { desc = "Toggle assistant window" })
end

return M
