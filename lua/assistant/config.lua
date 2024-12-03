---@class AssistantConfig
local AssistantConfig = {}

AssistantConfig.commands = {}
AssistantConfig.time_limit = 5000

function AssistantConfig.init(opts)
  if opts then
    AssistantConfig.commands = vim.tbl_deep_extend("force", AssistantConfig.commands, opts.commands or {})
    AssistantConfig.time_limit = opts.time_limit or AssistantConfig.time_limit
  end
end

return AssistantConfig
