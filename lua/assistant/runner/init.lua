local compiler = require("assistant.runner.compiler")
local executor = require("assistant.runner.executor")
local store = require("assistant.store")

local M = {}

function M.run_unique(index)
  compiler.compile(function()
    store.PROBLEM_DATA["tests"][index].status = "RUNNING"
    store.PROBLEM_DATA["tests"][index].group = "AssistantRunning"
    store.PROBLEM_DATA["tests"][index].stdout = ""
    store.PROBLEM_DATA["tests"][index].stderr = ""
    store.PROBLEM_DATA["tests"][index].start_at = 0

    executor.execute(index)
  end)
end

function M.run_all()
  compiler.compile(function()
    for i = 1, #store.PROBLEM_DATA["tests"] do
      store.PROBLEM_DATA["tests"][i].status = "RUNNING"
      store.PROBLEM_DATA["tests"][i].group = "AssistantRunning"
      store.PROBLEM_DATA["tests"][i].stdout = ""
      store.PROBLEM_DATA["tests"][i].stderr = ""
      store.PROBLEM_DATA["tests"][i].start_at = 0
    end

    for i = 1, #store.PROBLEM_DATA["tests"] do
      executor.execute(i)
    end
  end)
end

return M
