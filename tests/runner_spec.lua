---@diagnostic disable: undefined-field, undefined-global

local runner = require("assistant.runner").new()

describe("runner", function()
  it("can be initialized", function()
    runner:init({
      tests = {},
      command = { compile = {}, execute = {} },
      time_limit = 5000,
      cmp_cb = function() end,
      exe_cb = function() end,
    })

    if runner.tests == nil then
      assert(false, "runner.tests is a nil value")
    end
    if runner.command == nil then
      assert(false, "runner.command is a nil value")
    end
    if runner.time_limit == nil then
      assert(false, "runner.time_limit is a nil value")
    end
    if runner.cmp_cb == nil then
      assert(false, "runner.cmp_cb is a nil value")
    end
    if runner.cmp_cb == nil then
      assert(false, "runner.exe_cb is a nil value")
    end
  end)
end)
