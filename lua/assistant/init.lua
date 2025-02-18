local M = {}

-- Initializer for given `module_list` which are necessary to load at startup
---@param module_list {name:string,opts:table}[]
function M.init_all(module_list)
  for _, module in ipairs(module_list) do
    require("assistant." .. module.name).init(module.opts)
  end
end

-- Setup function for loading and create user command
---@param opts Ast.Config
function M.setup(opts)
  -- vim.api.nvim_create_user_command("AssistantToggle", ui.toggle, {})
  M.init_all({
    { name = "config", opts = opts },
    { name = "ui.groups" },
    -- { name = "core.tcplistener" },
  })
end

return M
