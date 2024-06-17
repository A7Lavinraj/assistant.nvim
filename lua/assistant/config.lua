local M = {}

M.commands = {
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

M.time_limit = 5000

M.tabs = {
  {
    title = " 󰟍 Assistant.nvim ",
    isActive = true,
  },
  {
    title = "  Run Test ",
    isActive = false,
  },
}

function M.load(opts)
  if opts then
    M.commands = vim.tbl_deep_extend("force", opts.commands or {})
    M.time_limit = opts.time_limit or M.time_limit
  end
end

return M
