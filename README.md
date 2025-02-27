<h1 align="center">Assistant.nvim - Neovim Plugin for Competitive Programming</h1>

<br>

<p align="center">
  <img alt="Latest release" src="https://img.shields.io/github/v/release/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41&include_prerelease&sort=semver" />
  <img alt="Last commit" src="https://img.shields.io/github/last-commit/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=8bd5ca&logoColor=D9E0EE&labelColor=302D41"/>
  <img alt="License" src="https://img.shields.io/github/license/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
  <img alt="Stars" src="https://img.shields.io/github/stars/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=starship&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" />
  <img alt="Issues" src="https://img.shields.io/github/issues/A7Lavinraj/assistant.nvim?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=D9E0EE&labelColor=302D41" />
  <img alt="Repo Size" src="https://img.shields.io/github/repo-size/A7Lavinraj/assistant.nvim?color=%23DDB6F2&label=SIZE&logo=codesandbox&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41" />
</p>

<br>

<p align="center"><strong>Assistant.nvim</strong> is a powerful and efficient Neovim plugin designed for competitive programmers. It automates the testing workflow, making it faster and more convenient to run test cases directly inside Neovim.</p>

<br>

![DEMO](https://github.com/user-attachments/assets/24a89357-8ae9-48fa-9c81-5bf97160550a)

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
    dependencies = { "folke/snacks.nvim" }, -- optional but recommended
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
    commit = "ca42f5231203ff3c9356180f2d4ca96061a70ef4",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    keys = {
      { "<leader>a", "<cmd>Assistant<cr>", desc = "Assistant.nvim" }
    },
    opts = {}
}
```

<br>

## Default Configuration

```lua
{
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
