local loader = require("assistant.loader")

local M = {}

---@param opts AssistantConfig
function M.setup(opts)
  loader.load({
    { name = "config", opts = opts },
    { name = "observers" },
    { name = "server" },
    { name = "commands" },
  })
end

return M
