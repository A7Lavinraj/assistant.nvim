return {
  config = {
    commands = {
      python = {
        extension = "py",
        compile = nil,
        execute = { main = "python3", args = { "$FILENAME_WITH_EXTENSION" } },
      },
      cpp = {
        extension = "cpp",
        compile = { main = "g++", args = { "$FILENAME_WITH_EXTENSION", "-o", "$FILENAME_WITHOUT_EXTENSION" } },
        execute = { main = "./$FILENAME_WITHOUT_EXTENSION", args = nil },
      },
    },
    time_limit = 5000,
  },
  win_opts = {
    relative = "editor",
    width = 0.6,
    height = 0.8,
    style = "minimal",
  },
}
