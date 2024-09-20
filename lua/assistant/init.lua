local loader = require("assistant.loader")

local M = {}

---@param opts AssistantConfig
function M.setup(opts)
  loader.load({
    { name = "ui.themes" },
    { name = "config", opts = opts },
    { name = "observers" },
    { name = "commands" },
    { name = "server" },
  })
end

return M
