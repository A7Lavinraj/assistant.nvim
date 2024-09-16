local config = require("assistant.config")
local constants = require("assistant.constants")
local emitter = require("assistant.emitter")
local store = require("assistant.store")
local utils = require("assistant.utils")

local M = {}

function M.execute(index)
  local process = {
    stdin = vim.loop.new_pipe(),
    stdout = vim.loop.new_pipe(),
    stderr = vim.loop.new_pipe(),
    timer = vim.loop.new_timer(),
  }

  local command = utils.interpolate(
    store.FILENAME_WITH_EXTENSION,
    store.FILENAME_WITHOUT_EXTENSION,
    config.commands[store.FILETYPE].execute
  )

  if not command then
    return
  end

  local test = store.PROBLEM_DATA["tests"][index]
  process.handle, process.id = vim.loop.spawn(command.main, {
    args = command.args,
    stdio = { process.stdin, process.stdout, process.stderr },
  }, function(code, signal)
    process.code, process.signal = code, signal
    store.PROBLEM_DATA["tests"][index].end_at = vim.loop.now()

    if process.code == 0 then
      if test.end_at - test.start_at > config.time_limit then
        test.status = "TIME LIMIT EXCEEDED"
        test.expand = true
        test.group = "AssistantKilled"
      elseif utils.compare(test.stdout, test.output) then
        test.status = "PASSED"
        test.expand = false
        test.group = "AssistantPassed"
      else
        test.status = "FAILED"
        test.expand = true
        test.group = "AssistantFailed"
      end

      vim.schedule(function()
        emitter.emit("AssistantRender")
      end)
    end

    if not process.stdin:is_closing() then
      process.stdin:close()
    end

    if not process.handle:is_closing() then
      process.handle:close()
    end

    if not process.timer:is_active() then
      process.timer:stop()
    end

    if not process.timer:is_closing() then
      process.timer:close()
    end
  end)

  test.status = "RUNNING"
  test.group = "AssistantRunning"
  test.start_at = vim.loop.now()
  test.end_at = test.start_at
  vim.schedule(function()
    emitter.emit("AssistantRender")
  end)
  process.timer:start(config.time_limit, 0, function()
    if not process.timer:is_active() then
      process.timer:stop()
    end

    if not process.timer:is_closing() then
      process.timer:close()
    end

    test.end_at = vim.loop.now()

    if process.handle and process.handle:is_active() then
      process.handle:kill()
    end
  end)

  vim.loop.write(process.stdin, test.input)
  vim.loop.shutdown(process.stdin)
  vim.loop.read_start(process.stdout, function(err, data)
    if err or not data then
      if process.stdout:is_readable() then
        process.stdout:read_stop()
      end

      if process.stdout:is_closing() then
        process.stdout:close()
      end
    else
      if #test.stdout < constants.MAX_RENDER_LIMIT then
        test.stdout = test.stdout .. utils.get_stream_data(data)
      end
    end
  end)
  vim.loop.read_start(process.stderr, function(err, data)
    if err or not data then
      if process.stderr:is_readable() then
        process.stderr:read_stop()
      end

      if process.stderr:is_closing() then
        process.stderr:close()
      end
    else
      if #test.stderr < constants.MAX_RENDER_LIMIT then
        test.stderr = test.stderr .. utils.get_stream_data(data)
      end
    end
  end)
end

return M
