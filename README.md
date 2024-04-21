# Assistant.nvim

A light-weight competitive programming code tester.

## Setup with [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "A7lavinraj/assistant.nvim"
  config = function()
    require("assistant").setup()
  end
}
```

## Usage

```lua
-- Commands to interact with plugin.
vim.cmd("AssistantRecieve")
vim.cmd("AssistantRuntest")
vim.cmd("AssistantToggle")

-- Mapping to interact with plugin.
local opts = { silent = true, noremap = true }

vim.keymap.set("n", "<leader>af", "<cmd>AssistantRecieve<cr>", opts)
vim.keymap.set("n", "<leader>at", "<cmd>AssistantRuntest<cr>", opts)
vim.keymap.set("n", "<leader>ao", "<cmd>AssistantToggle<cr>", opts)
```
