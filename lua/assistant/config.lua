local M = {}

M.default = {
  commands = {
    cpp = {
      extension = "cpp",
      compile = { "g++", "$FILENAME_WITH_EXTENSION", "-o", "$FILENAME_WITHOUT_EXTENSION" },
      execute = { "./$FILENAME_WITHOUT_EXTENSION" },
    },
    python = {
      extension = "py",
      compile = nil,
      execute = { "python3", "$FILENAME_WITH_EXTENSION" },
    },
  },
  time_limit = 5000,
}

M.update = function(opts)
  for option, value in pairs(M.default) do
    M.default[option] = opts[option] or value
  end
end

M.load = function()
  vim.api.nvim_create_user_command("AssistantToggle", require("assistant.ui").toggle, {})
end

return M
