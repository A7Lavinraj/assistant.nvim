local config = require("assistant.config")
local constants = require("assistant.constants")
local emit = require("assistant.emitter")
local store = require("assistant.store")

---@param received string
---@return string
local function get_stream_data(received)
  return table.concat(vim.split(string.gsub(received, "\r\n", "\n"), "\n", { plain = true }), "\n")
end

---@param stdout string
---@param expected string
---@return boolean
local function compare(stdout, expected)
  local function process_str(str)
    return (str or ""):gsub("\n", " "):gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")
  end

  return process_str(stdout) == process_str(expected)
end

---@param FILENAME_WITH_EXTENSION string | nil
---@param FILENAME_WITHOUT_EXTENSION string | nil
---@param command table | nil
---@return table | nil
local function interpolate(FILENAME_WITH_EXTENSION, FILENAME_WITHOUT_EXTENSION, command)
  if not command then
    return nil
  end

  local function replace(filename)
    return filename
      :gsub("%$FILENAME_WITH_EXTENSION", FILENAME_WITH_EXTENSION)
      :gsub("%$FILENAME_WITHOUT_EXTENSION", FILENAME_WITHOUT_EXTENSION)
  end

  local modified = vim.deepcopy(command)

  if modified.main then
    modified.main = replace(modified.main)
  end

  if modified.args then
    for i = 1, #command.args do
      modified.args[i] = replace(command.args[i])
    end
  end

  return modified
end

return function(index)
  local process = {
    stdin = vim.loop.new_pipe(),
    stdout = vim.loop.new_pipe(),
    stderr = vim.loop.new_pipe(),
    timer = vim.loop.new_timer(),
  }

  local command = interpolate(
    store.FILENAME_WITH_EXTENSION,
    store.FILENAME_WITHOUT_EXTENSION,
    config.commands[store.FILETYPE].execute
  )

  if not command then
    return
  end

  local test = store.PROBLEM_DATA["tests"][index]
  ---@diagnostic disable-next-line: missing-fields
  process.handle, process.id = vim.loop.spawn(command.main, {
    args = command.args,
    stdio = { process.stdin, process.stdout, process.stderr },
  }, function(code, signal)
    process.code, process.signal = code, signal
    store.PROBLEM_DATA["tests"][index].end_at = vim.loop.now()

    if process.code == 0 then
      if test.end_at - test.start_at > config.time_limit then
        test.status = "TIME LIMIT EXCEEDED"
        test.group = "AssistantKilled"
      elseif compare(test.stdout, test.output) then
        test.status = "PASSED"
        test.group = "AssistantPassed"
      else
        test.status = "FAILED"
        test.group = "AssistantFailed"
      end

      vim.schedule(function()
        emit("AssistantRender")
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
    emit("AssistantRender")
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
      ---@diagnostic disable-next-line: missing-parameter
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
        test.stdout = test.stdout .. get_stream_data(data)
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
        test.stderr = test.stderr .. get_stream_data(data)
      end
    end
  end)
end
