---@class Ast.Config.Core
---@field process_budget integer
---@field port integer

---@class Ast.Config.UI
---@field width number
---@field height number
---@field backdrop integer
---@field border string
---@field icons table<string, string|string[]>

---@class Ast.Config.Command.Opts
---@field extension? string
---@field compile? { main?: string, args?: string[] }
---@field execute? { main?: string, args?: string[] }

---@alias Ast.Config.Command table<string, Ast.Config.Command.Opts>

---@class Ast.Config.Defaults
---@field commands Ast.Config.Command[]
---@field ui Ast.Config.UI
---@field core Ast.Config.Core

---@class Ast.Config
---@field private _defaults Ast.Config.Defaults
---@field opts Ast.Config.Defaults
local M = {}

M._defaults = {
  commands = {
    python = {
      extension = "py",
      compile = nil,
      execute = {
        main = "python3",
        args = { "$FILENAME_WITH_EXTENSION" },
      },
    },
    cpp = {
      extension = "cpp",
      compile = {
        main = "g++",
        args = { "$FILENAME_WITH_EXTENSION", "-o", "$FILENAME_WITHOUT_EXTENSION" },
      },
      execute = {
        main = "./$FILENAME_WITHOUT_EXTENSION",
        args = nil,
      },
    },
  },
  ui = {
    width = 0.8,
    height = 0.8,
    backdrop = 60,
    border = "single",
    icons = {
      title = " ",
      success = " ",
      failure = " ",
      unknown = " ",
      loading_frames = { "󰸴 ", "󰸵 ", "󰸸 ", "󰸷 ", "󰸶 " },
    },
  },
  core = {
    process_budget = 5000,
    port = 10043,
  },
}

function M.init(opts)
  M.opts = vim.tbl_deep_extend("force", M._defaults, opts or {})
end

return M
