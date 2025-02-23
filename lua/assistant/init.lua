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
  M.init_all({
    { name = "config", opts = opts },
    { name = "ui.groups" },
    { name = "core.tcplistener" },
  })

  vim.api.nvim_create_user_command("AssistantToggle", function()
    require("assistant.utils").notify_warn(
      "Please use `Assistant` command instead of `AssistantToggle`, it is deprecated now"
    )
    require("assistant.ui").show()
  end, {})
  vim.api.nvim_create_user_command("Assistant", require("assistant.ui").show, {})
end

return M
