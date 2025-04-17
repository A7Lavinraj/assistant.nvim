<h1 align="center">Assistant.nvim - Neovim Plugin for Competitive Programming</h1>

<br>

<p align="center">
  <img alt="Latest release" src="https://img.shields.io/github/v/release/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41&include_prerelease&sort=semver" />
  <img alt="License" src="https://img.shields.io/github/license/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
  <img alt="Stars" src="https://img.shields.io/github/stars/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" />
</p>

<br>

<p align="center">
    <strong>Assistant.nvim</strong> is a powerful and efficient Neovim plugin designed for competitive programmers. It automates the testing workflow, making it faster and more convenient to run test cases directly inside Neovim.
</p>

<br>

![DEMO](https://github.com/user-attachments/assets/123f3b3f-600c-4dde-8cc8-dbc6324fda2f)

<br>

## Sample fetching

https://github.com/user-attachments/assets/f5adea87-f2f8-4da7-94d7-5da726a5845c

<br>

## Running tests

https://github.com/user-attachments/assets/41002e98-109b-4486-9587-4a2fc1cc0769

<br>

> [!NOTE]
> Speed is crucial in competitive programming. Ensure that using this plugin enhances your workflow rather than slowing you down.

<br>

## Features

- **Automated Test Case Management**: Easily fetch and organize test cases from online judges.
- **Customizable Execution Commands**: Support for multiple programming languages with configurable commands.
- **Interactive UI**: A user-friendly interface for managing test cases.
- **Asynchronous Processing**: Ensures Neovim remains responsive during execution.

## Requirements

- **Neovim** `>= 0.9.5`
- [Competitive Companion Browser Extension](https://github.com/jmerle/competitive-companion)

<br>

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "A7lavinraj/assistant.nvim",
    lazy = false, -- Start TCP Listener on Neovim startup
    keys = {
        { "<leader>a", "<cmd>Assistant<cr>", desc = "Assistant.nvim" }
    },
    opts = {}
}
```

<br>

> [!NOTE]
> If you encounter issues with the latest updates, consider switching to the most stable version

<br>

```lua
{
    "A7lavinraj/assistant.nvim",
    commit = "70f5d65b4af38945962a3409a1c4a343cdd6e003",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    keys = {
        { "<leader>a", "<cmd>Assistant<cr>", desc = "Assistant.nvim" }
    },
    opts = {}
}
```

<br>

## Default setup

```lua
{
    'A7Lavinraj/assistant.nvim',
    lazy = false,
    keys = {
        { "<leader>a", "<cmd>Assistant<cr>", desc = "Assistant.nvim" }
    },
    config = function()
        local actions = require 'assistant.actions'
        require('assistant').setup({
            mappings = {
                picker = {
                    n = {
                        ['?'] = actions.which_key,
                        ['q'] = actions.quit,
                        ['<ESC>'] = actions.quit,
                        ['<C-c>'] = actions.quit,
                        ['<CR>'] = actions.picker_select,
                    },
                },
                wizard = {
                    n = {
                        ['?'] = actions.which_key,
                        ['q'] = actions.quit,
                        ['<ESC>'] = actions.quit,
                        ['<C-c>'] = actions.quit,
                        ['r'] = actions.run_tests,
                        ['s'] = actions.toggle_test_selection,
                        ['a'] = actions.toggle_all_test_selection,
                        ['c'] = actions.add_test,
                        ['d'] = actions.remove_tests,
                        ['e'] = actions.edit_test,
                        ['<C-l>'] = require('assistant.actions.interface').focus_detail,
                    },
                },
                dialog = {
                    n = {
                        ['?'] = actions.which_key,
                        ['q'] = actions.quit,
                        ['<ESC>'] = actions.quit,
                        ['<C-c>'] = actions.quit,
                    },
                },
                editor = {
                    n = {
                        ['?'] = actions.which_key,
                        ['q'] = actions.quit,
                        ['<ESC>'] = actions.quit,
                        ['<C-c>'] = actions.quit,
                        ['<CR>'] = actions.save_prompt_content,
                    },
                },
            },
            commands = {
                python = {
                    extension = "py",
                    template = nil,
                    compile = nil,
                    execute = {
                        main = "python3",
                        args = { "$FILENAME_WITH_EXTENSION" },
                    },
                },
                cpp = {
                    extension = "cpp",
                    template = nil,
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
                border = "single",
            },
            core = {
                process_budget = 5000,
                port = 10043,
            },
        })
    end
}
```

## Custom Command Configuration

To extend the configuration for **Python**, add the following to the `commands` table:

```lua
python = {
    extension = "py",
    compile = nil, -- Python doesn't require compilation
    execute = {
        main = "python3",
        args = { "$FILENAME_WITH_EXTENSION" }
    },
},
```

To check the file type of an open file in Neovim, run:

```lua
:lua print(vim.bo.filetype)
```

## Commands & Key Bindings

```lua
:Assistant
```

| Key       | Operation                             |
| --------- | ------------------------------------- |
| `?`       | Which key                             |
| `q`       | Close window                          |
| `r`       | Run current or selected test cases    |
| `c`       | Create an empty test case             |
| `d`       | Delete current or selected test cases |
| `e`       | Open edit window                      |
| `s`       | Toggle current test case selection    |
| `a`       | Toggle all test case selections       |
| `j`       | Move to next test case                |
| `k`       | Move to previous test case            |
| `<enter>` | Confirm changes in prompt             |
| `<c-l>`   | Navigate to right window              |
| `<c-h>`   | Navigate to left window               |

## Want to contribute?

Please read [CONTRIBUTING.md](https://github.com/A7Lavinraj/assistant.nvim/blob/main/CONTRIBUTING.md) to get started
