# Contributing to Assistant.nvim

Thank you for considering contributing to Assistant.nvim! We welcome all contributions, from bug reports and feature requests to code improvements and documentation updates

## How to contribute?

- **Report an issue if it hasn't already been reported**
- **Create a fork of this repository**
- **Clone down the fork**

  ```sh
  git clone repository-url
  ```

- **Setup project locally**

  Use the following code snippet to set up Assistant.nvim locally in your Lazy.nvim configuration

  <br>

  > Disable or remove any existing Assistant.nvim setup in your Lazy.nvim configuration, to avoid confliction

  <br>

  ```lua
  {
    "assistant.nvim",
    dir = "path-to-clone-fork",
    lazy = false,
    keys = {
      { "<leader>a", "<cmd>Assistant<cr>", desc = "Assistant.nvim" }
    },
    opts = {}
  }
  ```

- **Create new git branch**

  ```sh
  git checkout -b your-branch-name
  ```

  For example `git checkout -b feat/subtask-identification`

- **Make you changes**
- **Test your changes**

  Write tests for your changes if possible and run production check

  ```sh
  make
  ```

- **Commit your changes**

  Write a clear and concise message, for example

  ```sh
  git commit -am "feat(runner): implement subtask identification"
  ```

- **Push your branch**

  ```sh
  git push origin your-branch-name
  ```

- **Create pull request and you are done!**

## Need Help?

If you need any help or clarification, feel free to ask in the [discussions](https://github.com/A7Lavinraj/assistant.nvim/discussions) or comment on relevant issues.

Thank you for your contributions!
