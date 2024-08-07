---@class AssistantConfig
local AssistantConfig = {}

AssistantConfig.commands = {
  python = {
    extension = "py",
    compile = nil,
    execute = { main = "python3", args = { "$FILENAME_WITH_EXTENSION" } },
  },
  cpp = {
    extension = "cpp",
    compile = { main = "g++", args = { "$FILENAME_WITH_EXTENSION", "-o", "$FILENAME_WITHOUT_EXTENSION" } },
    execute = { main = "./$FILENAME_WITHOUT_EXTENSION", args = nil },
  },
}

AssistantConfig.time_limit = 5000

AssistantConfig.tabs = {
  {
    title = " 󰟍 Assistant.nvim ",
    isActive = true,
  },
  {
    title = "  Run Test ",
    isActive = false,
  },
}

function AssistantConfig.load(opts)
  if opts then
    AssistantConfig.commands = vim.tbl_deep_extend("force", AssistantConfig.commands, opts.commands or {})
    AssistantConfig.time_limit = opts.time_limit or AssistantConfig.time_limit
    AssistantConfig.border = opts.border
  end
end

return AssistantConfig
