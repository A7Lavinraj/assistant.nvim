local tabs = require("assistant.ui.tabs")
local window = require("assistant.ui.window").new()
require("assistant.ui.colors").load()

local M = {}

local function set_keymaps()
  local keys = {
    {
      lhs = "q",
      rhs = function()
        window:delete_window()
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Close", buffer = window.buf },
    },
    {
      lhs = "<tab>",
      rhs = function()
        window.state.tab = (window.state.tab + 1) % #window.buttonset.buttons
        window.buttonset:click(window.state.tab + 1)
        tabs[window.state.tab + 1](window)
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Tab CyclicNext", buffer = window.buf },
    },
    {
      lhs = "<enter>",
      rhs = function()
        local current_line = vim.api.nvim_get_current_line()
        local number = current_line:match("Testcase #(%d+): %a+")

        if number then
          local test = window.state.test_data["tests"][tonumber(number)]

          if not test.expand then
            test.expand = true
          else
            test.expand = false
          end

          window.renderer:tests(window.state.test_data["tests"], window)
        end
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Expand Test", buffer = window.buf },
    },
    {
      lhs = "r",
      rhs = function()
        local current_line = vim.api.nvim_get_current_line()
        local number = current_line:match("Testcase #(%d+): %a+")

        if number then
          window.runner:run_unique(tonumber(number))
        end
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Run Test", buffer = window.buf },
    },
    {
      lhs = "R",
      rhs = function()
        window.runner:run_all()
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Run Test", buffer = window.buf },
    },
  }

  for _, key in pairs(keys) do
    vim.keymap.set("n", key.lhs, key.rhs, key.opts)
  end
end

function M.open()
  window:create_window()
  set_keymaps()
  window.buttonset:click(window.state.tab + 1)
  tabs[window.state.tab + 1](window)
end

function M.close()
  window:delete_window()
end

function M.toggle()
  if window.is_open then
    M.close()
  else
    M.open()
  end
end

return M
