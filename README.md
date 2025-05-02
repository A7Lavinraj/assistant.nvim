<p align="center">
  <img width="128" height="128" alt='Assistant.nvim Logo' src="https://github.com/user-attachments/assets/720b55eb-9fa3-4eb7-9bc0-a439859d007f" />
</p>

<h1 align="center">Assistant.nvim</h1>

<p align="center">
  <img alt="Latest release" src="https://img.shields.io/github/v/release/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41&include_prerelease&sort=semver" />
  <img alt="License" src="https://img.shields.io/github/license/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
  <img alt="Stars" src="https://img.shields.io/github/stars/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" />
</p>

<p align="center">A powerful and efficient Neovim plugin designed for competitive programmers. It automates the testing workflow, making it faster and more convenient to run test cases directly inside Neovim</p>

<br>

<div align="center">

  ![showcase](https://github.com/user-attachments/assets/3f4e910e-deea-4946-ad0d-7ab2541084f7)

</div>

<br>

> [!NOTE]
> Speed is crucial in competitive programming. Ensure that using this plugin enhances your workflow rather than slowing you down.

<br>

## Features

- **Automated Test Case Management**: Easily fetch and organize test cases from online judges.
- **Customizable Execution Commands**: Support for multiple programming languages with configurable commands.
- **Interactive UI**: A user-friendly interface for managing test cases.
- **Asynchronous Processing**: Ensures Neovim remains responsive during execution.

<br>

## Requirements

- **Neovim** `>= 0.9.5`
- [Competitive Companion Browser Extension](https://github.com/jmerle/competitive-companion)

<br>

## Installation Using [lazy.nvim](https://github.com/folke/lazy.nvim)

### latest setup

```lua
{
    "A7lavinraj/assistant.nvim",
    lazy = false,
    keys = {
        { "<leader>a", "<cmd>Assistant<cr>", desc = "Assistant.nvim" }
    },
    opts = {}
}
```

### stable setup

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

## Default configuration

```lua
{
    mappings = {},
    commands = {
        python = {
            extension = 'py',
            template = nil,
            compile = nil,
            execute = {
                main = 'python3',
                args = { '$FILENAME_WITH_EXTENSION' },
            },
        },
        cpp = {
            extension = 'cpp',
            template = nil,
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
        border = 'single',
        diff_mode = false,
    },
    core = {
        process_budget = 5000,
        port = 10043,
        filename_generator = nil
    },
}
```

<br>

<div align="center">
  <h2>Want to contribute?</h2>

  Please read [CONTRIBUTING.md](https://github.com/A7Lavinraj/assistant.nvim/blob/main/CONTRIBUTING.md) to get started
</div>
