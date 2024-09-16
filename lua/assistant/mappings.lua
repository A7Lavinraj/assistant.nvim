local emitter = require("assistant.emitter")
local previewer = require("assistant.ui.previewer")
local prompt = require("assistant.ui.prompt")
local runner = require("assistant.runner")
local store = require("assistant.store")
local ui = require("assistant.ui")

local M = {}

function M.load()
  ui:on_key("n", "q", function()
    ui:remove()
    previewer:remove()
  end)
  previewer:on_key("n", "q", function()
    ui:remove()
    previewer:remove()
  end)
  ui:on_key("n", "<esc>", function()
    ui:remove()
    previewer:remove()
  end)
  ui:on_key("n", "r", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("#(%d+):")

    if number then
      runner.run_unique(tonumber(number))
    end
  end)
  ui:on_key("n", "R", function()
    runner.run_all()
  end)
  ui:on_key("n", "c", function()
    if not store.PROBLEM_DATA then
      store.PROBLEM_DATA = { tests = {} }
    end

    table.insert(store.PROBLEM_DATA["tests"], { input = "...", output = "..." })
    emitter.emit("AssistantRender")
  end)
  ui:on_key("n", "d", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      table.remove(store.PROBLEM_DATA["tests"], tonumber(number))
      emitter.emit("AssistantRender")
    end
  end)
  ui:on_key("n", "i", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      prompt:open(tonumber(number), "input")
    end
  end)
  ui:on_key("n", "e", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      prompt:open(tonumber(number), "output")
    end
  end)
  ui:on_key("n", "<Tab>", function()
    vim.fn.win_gotoid(previewer.state.win)
  end)
  previewer:on_key("n", "<Tab>", function()
    vim.fn.win_gotoid(ui.state.win)
  end)
end

return M
