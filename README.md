<h1 align="center">Assistant.nvim</h1>

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

<p align="center"><strong>Assistant.nvim</strong> is a Neovim plugin that provides various features
related to sample data testing in competitive programming scenarios.</p>

<br>

![DEMO](https://github.com/user-attachments/assets/1f96629d-cdce-4e8d-836f-b10f55768212)

<br>

## Features

- ⚡ Blazingly fast.
- 🔓 Highly customizable.
- 🌞 Supports both environment and custom themes.
- 😃 Easy to use.

<br>

> [!WARNING]
One important factor in competitive programming is **Speed**.
Make sure you don't compromise on that while using some fancy plugin or software.

<br>

## Requirements

- **NEOVIM VERSION** >= `0.9.5`
- [Competitive Companion Browser extension](https://github.com/jmerle/competitive-companion)

<br>

## Setup with [Lazy.nvim](https://github.com/folke/lazy.nvim)

### Quick start

```lua
{
    "A7lavinraj/assistant.nvim",
    dependencies = { "stevearc/dressing.nvim" }, -- optional but recommended
    keys = {
      {
        "<leader>a",
        "<cmd>AssistantToggle<cr>",
        desc = "Toggle Assistant.nvim window"
      }
    },
    opts = {}
}
```

### Default configuration

```lua
{
  commands = {
    python = {
      extension = "py",
      template = nil, -- path to the template file
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
        args = { 
          "$FILENAME_WITH_EXTENSION",
          "-o",
          "$FILENAME_WITHOUT_EXTENSION"
        },
      },
      execute = {
        main = "./$FILENAME_WITHOUT_EXTENSION",
        args = nil,
      },
    },
  },
  ui = {
    icons = {
      success = "",
      failure = "",
      unknown = "",
      loading = { "󰸴", "󰸵", "󰸸", "󰸷", "󰸶" },
    },
  },
  core = {
    process_budget = 5000,
  },
}
```

<br>

## Explanation of above code snippet

- First line points to github repository from where the plugin is get installed.
- Second line is the dependency array for the plugin, In this case its [Dressing.nvim](https://github.com/stevearc/dressing.nvim)
- Third line contains the options table to customize plugin:

<br>

```sh
g++ example.cpp -o example # {main} {arg1} {args2} {arg3}
```

<br>

Above code snippet is a command to compile a C++ file, If you take a closure look
on the comment right in front of command you can guess
`main = g++`, `arg1 = example.cpp`, `arg2 = -o` and `arg3 = example`,
So if i want to extend the configuration for `Python`,
I just need to add following code snippet to commands table.

<br>

```lua
python = {
    extension = "py", -- your preferred file extension for python file
    compile = nil, -- since python code doesn't get compiled so pass a nil
    execute = { -- {main} command and array of {args} as we saw earlier.
        main = "python3",
        args = { "$FILENAME_WITH_EXTENSION" }
    },
},
```

<br />

> [!NOTE]
> key to the new table is **type of file you want to run**. In this case is `python`,
you can get the correct file-type of file by just open that file inside neovim
and type the following command.

<br />

```lua
:lua print(vim.bo.filetype)
```

<br />

> There is only one command to interact with plugin `AssistantToggle`
which toggle the UI window of plugin and rest operations are done by key-mappings.

<br />

```lua
 -- command to open and close plugin window
:AssistantToggle
```

<br />

| Key       | Operation                                                 |
| --------- | --------------------------------------------------------- |
| `q`       | Close UI                                                  |
| `r`       | Run testcase on which the cursor is holded                |
| `R`       | Run all available testcases                               |
| `c`       | Create an empty testcase                                  |
| `d`       | Delete testcase on which the cursor is holded             |
| `e`       | Open prompt window for updating expect                    |
| `i`       | Open prompt window for updating input                     |
| `<enter>` | Confirm changes in prompt                                 |
| `<c-l>`   | Navigate to available right window otherwise close the UI |
| `<c-k>`   | Navigate to available up window otherwise close the UI    |
| `<c-h>`   | Navigate to available left window otherwise close the UI  |
| `<c-j>`   | Navigate to available down window otherwise close the UI  |
