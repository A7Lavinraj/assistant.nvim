---@diagnostic disable: missing-fields

vim.env.LAZY_STDPATH = ".tests"

load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- Check if running in GitHub Actions
local is_ci = vim.env.GITHUB_ACTIONS ~= nil

local assistant_spec = is_ci and { "A7Lavinraj/assistant.nvim" } -- Use GitHub repo in CI
  or { dir = "~/workspace/development/assistant.nvim" } -- Use local path for development

require("lazy.minit").setup({
  spec = {
    assistant_spec,
    { "echasnovski/mini.test", lazy = false },
  },
})

require("mini.test").run({
  collect = {
    find_files = function()
      return vim.fn.globpath("lua", "**/*_spec.lua", true, true)
    end,
  },
})
