local state = require 'assistant.state'
local M = {}

---@param opts Assistant.Config
function M.setup(opts)
  require('assistant.config').overwrite(opts)
  require('assistant.core.tcp').bind_server()

  vim.api.nvim_create_user_command('Assistant', function()
    require('assistant.builtins.__wizard').standard:show()
  end, { nargs = 0 })
end

---@return table
function M.status()
  return state.get_local_key 'status' or {}
end

return M
