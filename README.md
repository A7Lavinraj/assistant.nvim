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

<p align="center"><strong>Assistant.nvim</strong> is a modern neovim testing manager for competitive programmers. It comes with various basic and advanced features which automate the testing workflow
</p>

<br>

![DEMO](https://github.com/user-attachments/assets/24a89357-8ae9-48fa-9c81-5bf97160550a)

<br>

> [!WARNING]
> One important factor in competitive programming is **Speed**.
> Make sure you don't compromise on that while using some fancy plugin or software.

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
    dependencies = { "folke/snacks.nvim" }, -- optional but recommended
    lazy = false, -- if you want to start TCP Listener on neovim startup
    keys = {
      { "<leader>a", "<cmd>AssistantToggle<cr>", desc = "Assistant.nvim" }
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
    },
  }
```

<br>

## How to create custom command?

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
> you can get the correct file-type of file by just open that file inside neovim
> and type the following command.

<br />

```lua
:lua print(vim.bo.filetype)
```

<br />

> There is only one command to interact with plugin `Assistant`
> which toggle the UI window of plugin and rest operations are done by key-mappings.

<br />

```lua
 -- command to open and close plugin window
:Assistant
```

<br />

| Key       | Operation                            |
| --------- | ------------------------------------ |
| `q`       | Close window                         |
| `r`       | Run current or selected testcases    |
| `c`       | Create an empty testcase             |
| `d`       | Delete current or selected testcases |
| `e`       | Open edit window                     |
| `s`       | Toggle current testcase selection    |
| `a`       | Toggle all testcase selection        |
| `j`       | Move to next testcase                |
| `k`       | Move to previous testcase            |
| `<enter>` | Confirm changes in prompt            |
| `<c-l>`   | Navigate to available right window   |
| `<c-h>`   | Navigate to available left window    |
