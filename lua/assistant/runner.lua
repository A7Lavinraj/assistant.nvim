local config = require("assistant.config")
local store = require("assistant.store")
local ui = require("assistant.ui")
local utils = require("assistant.utils")
local M = {}

---@param callback function
function M.compile(callback)
  if not store.PROBLEM_DATA then
    return
  end

  local command = utils.interpolate(
    store.FILENAME_WITH_EXTENSION,
    store.FILENAME_WITHOUT_EXTENSION,
    config.commands[store.FILETYPE].compile
  )
  store.COMPILE_STATUS = { code = nil, error = nil }

  if not command then
    callback()
  else
    for i = 1, #store.PROBLEM_DATA["tests"] do
      store.PROBLEM_DATA["tests"][i].status = "COMPILING"
      store.PROBLEM_DATA["tests"][i].group = "AssistantYellow"
    end

    ui.render_home()
    vim.fn.jobstart(vim.iter({ command.main, command.args }):flatten():totable(), {
      stderr_buffered = true,
      on_stderr = function(_, data)
        store.COMPILE_STATUS.error = data
      end,
      on_exit = function(_, code)
        store.COMPILE_STATUS.code = code

        if store.COMPILE_STATUS.code == 0 then
          callback()
        else
          ui.render_home()
          store.write()
        end
      end,
    })
  end
end

---@param index number
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
  ---@diagnostic disable-next-line: missing-fields
  process.handle, process.id = vim.loop.spawn(command.main, {
    args = command.args,
    stdio = { process.stdin, process.stdout, process.stderr },
  }, function(code, signal)
    process.code, process.signal = code, signal
    test.end_at = vim.loop.now()

    if process.code == 0 then
      if test.end_at - test.start_at > config.time_limit then
        test.status = "TIME LIMIT EXCEEDED"
        test.group = "AssistantRed"
      elseif utils.compare(test.stdout, test.output) then
        test.status = "PASSED"
        test.group = "AssistantGreen"
      else
        test.status = "FAILED"
        test.group = "AssistantRed"
      end

      vim.schedule(function()
        store.write()
        ui.render_home()
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
  test.group = "AssistantYellow"
  test.start_at = vim.loop.now()
  test.end_at = test.start_at
  test.stdout = ""
  test.stderr = ""
  vim.schedule(function()
    ui.render_home()
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

  vim.loop.write(process.stdin, test.input or "")
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
      test.stdout = test.stdout .. utils.get_stream_data(data)
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
      test.stderr = test.stderr .. utils.get_stream_data(data)
    end
  end)
end

function M.run_unique()
  local index = utils.get_current_line_number()

  if not index then
    return
  end

  M.compile(function()
    M.execute(index)
  end)
end

function M.run_all()
  M.compile(function()
    for i = 1, #store.PROBLEM_DATA["tests"] do
      M.execute(i)
    end
  end)
end

function M.create_test()
  store.PROBLEM_DATA = store.PROBLEM_DATA or {}
  store.PROBLEM_DATA["tests"] = store.PROBLEM_DATA["tests"] or {}
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
    ui.render_home()
  end
end

return M
