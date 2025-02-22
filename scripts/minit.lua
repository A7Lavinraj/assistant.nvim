---@diagnostic disable: missing-fields

vim.env.LAZY_STDPATH = ".tests"

load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").setup({
  spec = {
    { dir = "~/workspace/development/assistant.nvim" },
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
