local M = {}

---@param opts Assistant.Config
function M.setup(opts)
  require('assistant.config').overwrite(opts)
  require('assistant.core.tcp').bind_server()
end

return M
