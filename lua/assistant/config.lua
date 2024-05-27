local default = require("assistant.defaults")
local M = {}

M.default = {}

M.update = function(opts)
  M.default = vim.tbl_deep_extend("force", default["config"], opts)
end

M.load = function()
  vim.api.nvim_create_user_command("AssistantToggle", require("assistant.ui").toggle, {})
end

return M
