local tabs = require("assistant.ui.tabs")
local window_main = require("assistant.ui.window").new()
require("assistant.ui.colors").load()

local M = {}

local function set_keymaps()
  local keys = {
    {
      lhs = "q",
      rhs = function()
        window_main:delete_window()
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Close", buffer = window_main.buf },
    },
    {
      lhs = "<tab>",
      rhs = function()
        window_main.state.tab = (window_main.state.tab + 1) % #window_main.buttonset.buttons
        window_main.buttonset:click(window_main.state.tab + 1)
        tabs[window_main.state.tab + 1](window_main)
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Tab CyclicNext", buffer = window_main.buf },
    },
    {
      lhs = "<enter>",
      rhs = function()
        local current_line = vim.api.nvim_get_current_line()
        local number = current_line:match("Testcase #(%d+): %a+")

        if number then
          local test = window_main.state.test_data["tests"][tonumber(number)]

          if not test.expand then
            test.expand = true
          else
            test.expand = false
          end

          window_main.renderer:tests(window_main.state.test_data["tests"], window_main)
        end
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Expand Test", buffer = window_main.buf },
    },
    {
      lhs = "r",
      rhs = function()
        local current_line = vim.api.nvim_get_current_line()
        local number = current_line:match("Testcase #(%d+): %a+")

        if number then
          window_main.runner:run_unique(tonumber(number))
        end
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Run Test", buffer = window_main.buf },
    },
    {
      lhs = "R",
      rhs = function()
        if window_main.state.tab ~= 1 then
          return
        end

        window_main.runner:run_all()
      end,
      opts = { noremap = true, silent = true, desc = "Assistant Run Test", buffer = window_main.buf },
    },
  }

  for _, key in pairs(keys) do
    vim.keymap.set("n", key.lhs, key.rhs, key.opts)
  end
end

function M.open()
  window_main:create_window()
  set_keymaps()
  window_main.buttonset:click(window_main.state.tab + 1)
  tabs[window_main.state.tab + 1](window_main)
end

function M.close()
  window_main:delete_window()
end

function M.toggle()
  if window_main.is_open then
    M.close()
  else
    M.open()
  end
end

return M
