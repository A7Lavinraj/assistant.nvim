local compile = require("assistant.runner.compiler")
local execute = require("assistant.runner.executor")
local store = require("assistant.store")

local M = {}

function M.run_unique(index)
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

return M
