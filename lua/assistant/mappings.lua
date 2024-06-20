local config = require("assistant.config")
local emitter = require("assistant.emitter")
local runner = require("assistant.runner")
local store = require("assistant.store")
local ui = require("assistant.ui")

local M = {}

function M.load()
  ui.on_key("n", "q", ui.close_window)
  ui.on_key("n", "<tab>", function()
    store.TAB = store.TAB % #config.tabs + 1

    emitter.emit("AssistantRender")
  end)
  ui.on_key("n", "<enter>", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      local test = store.PROBLEM_DATA["tests"][tonumber(number)]

      if not test.expand then
        test.expand = true
      else
        test.expand = false
      end

      emitter.emit("AssistantRender")
    end
  end)
  ui.on_key("n", "r", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("#(%d+):")

    if number then
      runner.run_unique(tonumber(number))
    end
  end)
  ui.on_key("n", "R", runner.run_all)
end

return M
