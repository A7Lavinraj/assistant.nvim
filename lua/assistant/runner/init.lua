local compile = require("assistant.runner.compiler")
local execute = require("assistant.runner.executor")
local store = require("assistant.store")
local ui = require("assistant.ui")

local M = {}

function M.run_unique()
  local current_line = vim.api.nvim_get_current_line()
  local index = tonumber(current_line:match("testcase #(%d+)%s+"))

  if not index then
    return
  end

  local test = store.PROBLEM_DATA["tests"][index]

  compile(function()
    test.status = "RUNNING"
    test.group = "AssistantRunning"
    test.stdout = ""
    test.stderr = ""
    test.start_at = 0
    execute(index)
  end, index)
end

function M.run_all()
  compile(function()
    local tests = store.PROBLEM_DATA["tests"]

    for i = 1, #store.PROBLEM_DATA["tests"] do
      tests[i].status = "RUNNING"
      tests[i].group = "AssistantRunning"
      tests[i].stdout = ""
      tests[i].stderr = ""
      tests[i].start_at = 0
    end

    for i = 1, #store.PROBLEM_DATA["tests"] do
      execute(i)
    end
  end)
end

function M.create_test()
  if not store.PROBLEM_DATA then
    store.PROBLEM_DATA = {}
    store.PROBLEM_DATA["tests"] = {}
  end

  table.insert(store.PROBLEM_DATA["tests"], {})
  store.write()
  ui.render_home()
end

function M.remove_test()
  local current_line = vim.api.nvim_get_current_line()
  local index = tonumber(current_line:match("testcase #(%d+)%s+"))

  if not index then
    return
  end

  if store.PROBLEM_DATA then
    table.remove(store.PROBLEM_DATA["tests"], index)
    store.write()
    ui.render_home()
  end
end

return M
