local compiler = require("assistant.runner.compiler")
local executor = require("assistant.runner.executor")
local store = require("assistant.store")

local M = {}

function M.run_unique(index)
  local test = store.PROBLEM_DATA["tests"][index]
  compiler.compile(function()
    test.status = "RUNNING"
    test.group = "AssistantRunning"
    test.stdout = ""
    test.stderr = ""
    test.start_at = 0
    executor.execute(index)
  end, index)
end

function M.run_all()
  compiler.compile(function()
    local tests = store.PROBLEM_DATA["tests"]

    for i = 1, #store.PROBLEM_DATA["tests"] do
      tests[i].status = "RUNNING"
      tests[i].group = "AssistantRunning"
      tests[i].stdout = ""
      tests[i].stderr = ""
      tests[i].start_at = 0
    end

    for i = 1, #store.PROBLEM_DATA["tests"] do
      executor.execute(i)
    end
  end)
end

return M
