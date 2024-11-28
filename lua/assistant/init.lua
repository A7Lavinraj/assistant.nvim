local ui = require("assistant.ui")

local M = {}

function M.init_all(module_list)
  for _, module in ipairs(module_list) do
    require("assistant." .. module.name).init(module.opts)
  end
end

---@param opts AssistantConfig
function M.setup(opts)
  vim.api.nvim_create_user_command("AssistantToggle", ui.toggle, {})
  M.init_all({
    { name = "config", opts = opts },
    { name = "ui.groups" },
    { name = "listeners" },
  })
end

return M
