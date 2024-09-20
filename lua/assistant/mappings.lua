local emit = require("assistant.emitter")
local runner = require("assistant.runner")
local store = require("assistant.store")
local ui = require("assistant.ui")

local M = {}

function M.load()
  ui.main:on_key("n", "q", ui.remove)
  ui.main:on_key("n", "<esc>", ui.remove)
  ui.prev:on_key("n", "q", ui.remove)
  ui.prev:on_key("n", "<esc>", ui.remove)
  ui.main:on_key("n", "r", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("#(%d+):")

    if number then
      runner.run_unique(tonumber(number))
    end
  end)
  ui.main:on_key("n", "R", function()
    runner.run_all()
  end)
  ui.main:on_key("n", "c", function()
    if not store.PROBLEM_DATA then
      store.PROBLEM_DATA = { tests = {} }
    end

    table.insert(store.PROBLEM_DATA["tests"], { input = "...", output = "..." })
    emit("AssistantRender")
  end)
  ui.main:on_key("n", "d", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      table.remove(store.PROBLEM_DATA["tests"], tonumber(number))
      emit("AssistantRender")
    end
  end)
  ui.main:on_key("n", "i", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      ui.input(tonumber(number), "input")
    end
  end)
  ui.main:on_key("n", "e", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      ui.prompt:open(tonumber(number), "output")
    end
  end)
  ui.main:on_key("n", "<Tab>", function()
    vim.fn.win_gotoid(ui.prev.win)
  end)
  ui.prev:on_key("n", "<Tab>", function()
    vim.fn.win_gotoid(ui.main.win)
  end)
end

return M
