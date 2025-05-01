---@class Assistant.Config.Core
---@field process_budget integer
---@field port integer
---@field filename_generator fun(str: string): string

---@class Assistant.Config.UI
---@field border string
---@field diff_mode boolean

---@class Assistant.Config
---@field mappings table<string, table<"i"|"n"|"v", table<string, Assistant.Action|function>>>
---@field commands table<string, Assistant.Processor.SourceConfig>
---@field ui Assistant.Config.UI
---@field core Assistant.Config.Core

local config = {}

local defaults = {
  commands = {
    python = {
      extension = 'py',
      compile = nil,
      execute = {
        main = 'python3',
        args = { '$FILENAME_WITH_EXTENSION' },
      },
    },
    cpp = {
      extension = 'cpp',
      compile = {
        main = 'g++',
        args = { '$FILENAME_WITH_EXTENSION', '-o', '$FILENAME_WITHOUT_EXTENSION' },
      },
      execute = {
        main = './$FILENAME_WITHOUT_EXTENSION',
        args = nil,
      },
    },
  },
  ui = {
    diff_mode = false,
    border = 'rounded',
  },
  core = {
    process_budget = 5000,
    port = 10043,
  },
}

---@param opts? Assistant.Config
function config.overwrite(opts)
  config.values = vim.tbl_deep_extend('force', defaults, opts or {})
  config.namespace = vim.api.nvim_create_namespace 'assistant-nvim'
  config.augroup = vim.api.nvim_create_augroup('assistant-nvim', { clear = true })
end

return config
