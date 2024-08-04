local config = require("assistant.config")
local emitter = require("assistant.emitter")
local prompt = require("assistant.ui.prompt")
local runner = require("assistant.runner")
local store = require("assistant.store")
local ui = require("assistant.ui")

local M = {}

function M.load()
  ui.on_key("n", "q", ui.close_window)
  ui.on_key("n", "<esc>", function()
    prompt:close()
  end)
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
    if store.TAB ~= 2 then
      return
    end

    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("#(%d+):")

    if number then
      runner.run_unique(tonumber(number))
    end
  end)
  ui.on_key("n", "R", function()
    if store.TAB ~= 2 then
      return
    end

    runner.run_all()
  end)
  ui.on_key("n", "c", function()
    if store.TAB ~= 2 then
      return
    end

    if not store.PROBLEM_DATA then
      store.PROBLEM_DATA = { tests = {} }
    end

    table.insert(store.PROBLEM_DATA["tests"], { input = "...", output = "..." })
    emitter.emit("AssistantRender")
  end)
  ui.on_key("n", "d", function()
    if store.TAB ~= 2 then
      return
    end

    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      table.remove(store.PROBLEM_DATA["tests"], tonumber(number))
      emitter.emit("AssistantRender")
    end
  end)
  ui.on_key("n", "i", function()
    if store.TAB ~= 2 then
      return
    end

    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      prompt:open(tonumber(number), "input")
    end
  end)
  ui.on_key("n", "e", function()
    if store.TAB ~= 2 then
      return
    end

    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      prompt:open(tonumber(number), "output")
    end
  end)
end

return M
