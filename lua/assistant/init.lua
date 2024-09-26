local loader = require("assistant.loader")

local M = {}

---@param opts AssistantConfig
function M.setup(opts)
  loader.load({
    { name = "config", opts = opts },
    { name = "ui.themes" },
    { name = "observers" },
    { name = "commands" },
    { name = "server" },
  })
end

return M
