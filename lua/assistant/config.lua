---@class Assistant.Config.Core
---@field process_budget integer
---@field port integer

---@class Assistant.Config.UI
---@field border string

---@class Assistant.Config.Defaults
---@field mappings? table<string, table<"i"|"n"|"v", table<string, Assistant.Action|function>>>
---@field commands table<string, Assistant.Processor.SourceConfig>
---@field ui Assistant.Config.UI
---@field core Assistant.Config.Core

---@class Assistant.Config
---@field private _defaults Assistant.Config.Defaults
---@field namespace integer
---@field opts Assistant.Config.Defaults
local M = {}

M.namespace = vim.api.nvim_create_namespace 'assistant-nvim'
M.augroup = vim.api.nvim_create_augroup('assistant-nvim', { clear = true })

M._defaults = {
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
    border = 'rounded',
  },
  core = {
    process_budget = 5000,
    port = 10043,
  },
}

function M.overwrite(opts)
  M.values = vim.tbl_deep_extend('force', M._defaults, opts or {})
end

return M
