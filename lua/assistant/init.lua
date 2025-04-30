local M = {}

---@param opts Assistant.Config
function M.setup(opts)
  require('assistant.config').overwrite(opts)
  require('assistant.core.tcp').bind_server()

  vim.api.nvim_create_user_command('Assistant', function()
    require('assistant.builtins.__wizard').standard()
  end, { nargs = 0 })
end

return M
