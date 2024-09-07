local config = require("assistant.config")
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

  process.handle, process.id = vim.loop.spawn(command.main, {
    args = command.args,
    stdio = { process.stdin, process.stdout, process.stderr },
  }, function(code, signal)
    process.code, process.signal = code, signal

    if process.code == 0 then
      if
        utils.compare(
          store.PROBLEM_DATA["tests"][index].stdout,
          store.PROBLEM_DATA["tests"][index].output
        )
      then
        store.PROBLEM_DATA["tests"][index].status = "PASSED"
        store.PROBLEM_DATA["tests"][index].expand = false
        store.PROBLEM_DATA["tests"][index].group = "AssistantPassed"
      else
        store.PROBLEM_DATA["tests"][index].status = "FAILED"
        store.PROBLEM_DATA["tests"][index].expand = true
        store.PROBLEM_DATA["tests"][index].group = "AssistantFailed"
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

    store.PROBLEM_DATA["tests"][index].end_at = vim.loop.now()
  end)

  store.PROBLEM_DATA["tests"][index].status = "RUNNING"
  store.PROBLEM_DATA["tests"][index].group = "AssistantRunning"
  store.PROBLEM_DATA["tests"][index].start_at = vim.loop.now()

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

    store.PROBLEM_DATA["tests"][index].end_at = vim.loop.now()

    if store.PROBLEM_DATA["tests"][index].status == "RUNNING" then
      store.PROBLEM_DATA["tests"][index].status = "TIME LIMIT EXCEEDED"
      store.PROBLEM_DATA["tests"][index].group = "AssistantKilled"

      vim.schedule(function()
        emitter.emit("AssistantRender")
      end)
    end
  end)

  vim.loop.write(process.stdin, store.PROBLEM_DATA["tests"][index].input)
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
      store.PROBLEM_DATA["tests"][index].stdout = store.PROBLEM_DATA["tests"][index].stdout
        .. utils.get_stream_data(data)
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
      store.PROBLEM_DATA["tests"][index].stderr = store.PROBLEM_DATA["tests"][index].stderr
        .. utils.get_stream_data(data)
    end
  end)
end

return M
