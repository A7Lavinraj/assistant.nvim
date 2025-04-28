local Scheduler = require 'assistant.algos.scheduler'
local luv = vim.uv or vim.loop
local scheduler = Scheduler.new()
local Processor = {}

---@alias Assistant.Processor.Command { main?: string, args?: string[] }

---@class Assistant.Processor.SourceConfig
---@field extension string
---@field compile? Assistant.Processor.Command
---@field execute? Assistant.Processor.Command
---@field template? string

---@return Assistant.Processor.SourceConfig
local function get_source_config()
  local state = require 'assistant.state'
  local config = require 'assistant.config'
  ---@param str string
  ---@return string, integer
  local function format(str)
    local filename = state.get_global_key 'filename'
    local extension = state.get_global_key 'extension'
    return str
      :gsub('%$FILENAME_WITH_EXTENSION', string.format('%s.%s', filename, extension))
      :gsub('%$FILENAME_WITHOUT_EXTENSION', filename)
  end

  local command = vim.deepcopy(config.values.commands[state.get_global_key 'filetype'])

  if command.compile then
    command.compile.main = format(command.compile.main)

    for i = 1, #command.compile.args do
      command.compile.args[i] = format(command.compile.args[i])
    end
  end

  if command.execute then
    command.execute.main = format(command.execute.main)

    for i = 1, #(command.execute.args or {}) do
      command.execute.args[i] = format(command.execute.args[i])
    end
  end

  return command
end

---@class Assistant.Processor.Logs
---@field stdout string
---@field stderr string
---@field process_started_at integer
---@field process_ended_at integer

---@param cmd Assistant.Processor.Command
---@param stdin? string
---@param on_exit fun(code: integer, signal: integer, logs: Assistant.Processor.Logs)
---@return thread
local function get_process(cmd, stdin, on_exit)
  ---@param data string
  ---@return string
  local function get_stream_data(data)
    return table.concat(vim.split(string.gsub(data, '\r\n', '\n'), '\n', { plain = true }), '\n')
  end

  return coroutine.create(function()
    if not cmd then
      on_exit(0, 0, {
        stdout = '',
        stderr = '',
        process_started_at = 0,
        process_ended_at = 0,
      })
      return
    end

    local stdio = {
      luv.new_pipe(false),
      luv.new_pipe(false),
      luv.new_pipe(false),
    }

    local logs = {
      stdout = '',
      stderr = '',
    }

    local process = {
      timer = luv.new_timer(),
    }

    local co = coroutine.running()

    ---@diagnostic disable-next-line: missing-fields
    process.handle, process.pid = luv.spawn(cmd.main, {
      args = cmd.args,
      stdio = stdio,
    }, function(code, signal)
      for _, pipe in ipairs(stdio) do
        if not luv.is_closing(pipe) then
          luv.close(pipe)
        end
      end

      if not luv.is_closing(process.timer) then
        logs.process_ended_at = luv.now()
        luv.close(process.timer)
      end

      if coroutine.status(co) == 'suspended' then
        coroutine.resume(co)
      end

      on_exit(code, signal, logs)
    end)

    logs.process_started_at = luv.now()
    process.timer:start(require('assistant.config').values.core.process_budget, 0, function()
      if not process.timer:is_closing() then
        logs.process_ended_at = luv.now()
        process.timer:close()
      end

      if process.handle and process.handle:is_active() then
        luv.kill(process.pid, 15)
      end
    end)

    luv.read_start(stdio[2], function(err, chunk)
      if err or not chunk then
        luv.read_stop(stdio[2])

        if not luv.is_closing(stdio[2]) then
          luv.close(stdio[2])
        end
      else
        logs.stdout = logs.stdout .. get_stream_data(chunk)
      end
    end)

    luv.read_start(stdio[3], function(err, chunk)
      if err or not chunk then
        luv.read_stop(stdio[3])

        if not luv.is_closing(stdio[3]) then
          luv.close(stdio[3])
        end
      else
        logs.stderr = logs.stderr .. get_stream_data(chunk)
      end
    end)

    if stdin then
      luv.write(stdio[1], stdin, function()
        if not luv.is_closing(stdio[1]) then
          luv.close(stdio[1])
        end
      end)
    else
      if not luv.is_closing(stdio[1]) then
        luv.close(stdio[1])
      end
    end

    coroutine.yield()
  end)
end

---@param str_a string
---@param str_b string
---@return boolean
local function str_cmp(str_a, str_b)
  local function process_str(str)
    return (str or ''):gsub('\n', ' '):gsub('%s+', ' '):gsub('^%s', ''):gsub('%s$', '')
  end

  return process_str(str_a) == process_str(str_b)
end

---@param code integer
---@param signal integer
---@return string
local function get_process_status(code, signal)
  if signal == 0 and code == 0 then
    return 'OK'
  end

  if signal ~= 0 then
    local signal_status = {
      [1] = 'HU',
      [2] = 'IN',
      [3] = 'QT',
      [4] = 'IL',
      [6] = 'AB',
      [8] = 'FE',
      [9] = 'KI',
      [11] = 'SF',
      [13] = 'BP',
      [14] = 'TO',
      [15] = 'TE',
    }
    return signal_status[signal] or 'SG'
  end

  local exit_status = {
    [127] = 'NF',
    [126] = 'NP',
    [139] = 'SF',
    [137] = 'KI',
    [124] = 'TO',
    [255] = 'FE',
  }

  return exit_status[code] or 'FL'
end

---@param testcase_IDS integer[]
function Processor.run_testcases(testcase_IDS)
  local state = require 'assistant.state'
  local dialog = require('assistant.builtins.dialog').standard
  local wizard = state.get_global_key 'assistant_wizard'
  local cmd = get_source_config()

  scheduler:schedule(get_process(cmd.compile, nil, function(build_code, build_signal, build_logs)
    vim.schedule(function()
      wizard.window:set_win_config { title = string.format(' Wizard - %s ', state.get_global_key 'filename') }
    end)

    local build_status = get_process_status(build_code, build_signal)

    if build_status ~= 'OK' then
      vim.schedule(function()
        dialog:display(build_logs.stderr or build_logs.stdout, { prompt = ' Dialog - Build Error ' })
      end)
      return
    end

    local testcases = state.get_global_key 'tests'

    for _, testcase_ID in ipairs(testcase_IDS) do
      local testcase = testcases[testcase_ID]

      scheduler:schedule(
        get_process(cmd.execute, testcases[testcase_ID].input, function(exec_code, exec_signal, exec_logs)
          local exec_status = get_process_status(exec_code, exec_signal)

          testcase.stdout = exec_logs.stdout
          testcase.stderr = exec_logs.stderr
          testcase.time_taken = (exec_logs.process_ended_at - exec_logs.process_started_at) * 0.001

          if exec_status == 'OK' then
            testcase.status = str_cmp(testcase.stdout, testcase.output) and 'AC' or 'WA'
          else
            testcase.status = exec_status
          end

          vim.schedule(function()
            wizard.canvas:set(wizard.window.bufnr)
          end)
        end)
      )

      testcases[testcase_ID].status = 'RN'

      vim.schedule(function()
        wizard.canvas:set(wizard.window.bufnr)
      end)
    end
  end))

  wizard.window:set_win_config { title = string.format(' Wizard - %s: COMPILING ', state.get_global_key 'filename') }
end

return Processor
