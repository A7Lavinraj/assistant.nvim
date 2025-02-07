local actions = require("assistant.core.actions")
local config = require("assistant.config")
local state = require("assistant.state")
local ui = require("assistant.ui")
local utils = require("assistant.utils")
local luv = vim.uv or vim.loop
local M = {}
M.queue = {}
M.MAX_CONCURRENCY = 5
M.concurrency_count = 0
M.processor_status = "STOPPED"
M.compile_status = { code = 0, err = "" }
M.budget = config.options.core.process_budget or 5000

-- For windows python alias
local function resolve_command(cmd)
  if cmd:lower() == "python" then
    -- Try different Python commands in order
    local possible_commands = {"python3", "python", "py"}

    for _, possible_cmd in ipairs(possible_commands) do

      local handle = io.popen(string.format("where %s 2>nul", possible_cmd))

      if handle then
        local result = handle:read("*a")
        handle:close()
      
        if result and result ~= "" then
          return possible_cmd
        end
      end
    end
  end

  return cmd
end


---@return table
function M.get_cmd()
  local cmd = vim.deepcopy(config.options.commands[state.get_src_ft()] or {})

  local function format(filename)
    local name, ext = state.get_src_name()
    return filename
      :gsub("%$FILENAME_WITH_EXTENSION", string.format("%s.%s", name, ext))
      :gsub("%$FILENAME_WITHOUT_EXTENSION", name)
  end

  if cmd.compile ~= nil then
    cmd.compile.main = format(cmd.compile.main)

    for i = 1, #cmd.compile.args do
      cmd.compile.args[i] = format(cmd.compile.args[i])
    end
  end

  if cmd.execute ~= nil then
    cmd.execute.main = format(cmd.execute.main)

    for i = 1, #(cmd.execute.args or {}) do
      cmd.execute.args[i] = format(cmd.execute.args[i])
    end
  end

  return cmd
end

---@param test_id integer
function M._execute(test_id)
  local cmd = M.get_cmd()
  local process = {}
  local test = state.get_test_by_id(test_id)
  process.stdio = { luv.new_pipe(false), luv.new_pipe(false), luv.new_pipe(false) }
  process.timer = luv.new_timer()
  process.stdout = ""
  process.stderr = ""

  if not cmd.execute then
    return
  end

  local execute_command = resolve_command(cmd.execute.main)

  process.handle, process.pid = luv.spawn(
    execute_command,
    ---@diagnostic disable-next-line
    { stdio = process.stdio, args = cmd.execute.args },
    function(code, _)
      process.end_at = luv.now()

      for _, pipe in ipairs(process.stdio) do
        if not pipe:is_closing() then
          pipe:close()
        end
      end

      if not process.timer:is_closing() then
        process.timer:close()
      end

      if code == 0 then
        if (process.end_at - process.start_at) > M.budget then
          state.set_by_key("tests", function(value)
            value[test_id].stdout = process.stdout
            value[test_id].stderr = process.stderr
            value[test_id].status = "KILLED"
            value[test_id].group = "AssistantRed"
            value[test_id].time_taken = (process.end_at - process.start_at) * 0.001
            return value
          end)
          state.write_all()
        elseif utils.compare(process.stdout, test.output) then
          state.set_by_key("tests", function(value)
            value[test_id].stdout = process.stdout
            value[test_id].stderr = process.stderr
            value[test_id].status = "ACCEPTED"
            value[test_id].group = "AssistantGreen"
            value[test_id].time_taken = (process.end_at - process.start_at) * 0.001
            return value
          end)
          state.write_all()
        else
          state.set_by_key("tests", function(value)
            value[test_id].stdout = process.stdout
            value[test_id].stderr = process.stderr
            value[test_id].status = "WRONG ANSWER"
            value[test_id].group = "AssistantRed"
            value[test_id].time_taken = (process.end_at - process.start_at) * 0.001
            return value
          end)
          state.write_all()
        end
      else
        state.set_by_key("tests", function(value)
          value[test_id].stdout = process.stdout
          value[test_id].stderr = process.stderr
          value[test_id].status = "RUNTIME ERROR"
          value[test_id].group = "AssistantYellow"
          value[test_id].time_taken = (process.end_at - process.start_at) / 1e3
          return value
        end)
        state.write_all()
      end

      M.concurrency_count = M.concurrency_count - 1
      M.process_queue()
      vim.schedule(ui.render_home)
      actions.execution_status()
    end
  )

  if not process.handle then
    vim.notify("[Process]: unable to start execution", vim.log.levels.ERROR)

    for _, pipe in ipairs(process.stdio) do
      pipe:close()
    end
  end

  process.start_at = luv.now()
  state.set_by_key("tests", function(value)
    value[test_id].status = "RUNNING"
    value[test_id].group = "AssistantYellow"
    return value
  end)
  vim.schedule(ui.render_home)
  process.timer:start(M.budget, 0, function()
    if not process.timer:is_closing() then
      process.timer:close()
    end

    if process.handle and process.handle:is_active() then
      luv.kill(process.pid, 15)
    end

    state.set_by_key("tests", function(value)
      value[test_id].status = "KILLED"
      value[test_id].group = "AssistantRed"
      return value
    end)
    vim.schedule(ui.render_home)
  end)
  luv.write(process.stdio[1], test.input)
  luv.shutdown(process.stdio[1])
  luv.read_start(process.stdio[2], function(_, data)
    if data then
      process.stdout = process.stdout .. utils.get_stream_data(data)
    end
  end)
  luv.read_start(process.stdio[3], function(_, data)
    if data then
      process.stderr = process.stderr .. utils.get_stream_data(data)
    end
  end)
end

---@return thread
function M._compile()
  ---@type thread
  local thread = nil
  thread = coroutine.create(function()
    local cmd = M.get_cmd()
    local process = {}
    process.stdio = { nil, nil, luv.new_pipe(false) }
    process.stderr = ""
    process.handle, process.pid = luv.spawn(
      cmd.compile.main,
      ---@diagnostic disable-next-line
      { stdio = process.stdio, args = cmd.compile.args },
      function(code, _)
        for _, pipe in ipairs(process.stdio) do
          pipe:close()
        end

        M.compile_status.code = code
        M.compile_status.err = process.stderr
        coroutine.resume(thread)
      end
    )

    if not process.handle then
      vim.notify("[Process]: unable to start compilation", vim.log.levels.ERROR)

      for _, pipe in ipairs(process.stdio) do
        pipe:close()
      end
    end

    luv.read_start(process.stdio[3], function(_, data)
      if data then
        process.stderr = process.stderr .. utils.get_stream_data(data)
      end
    end)

    coroutine.yield()
  end)

  return thread
end

---@param test_id integer
---@return boolean
function M.is_unique_test(test_id)
  for i = 1, #M.queue do
    if M.queue[i] == test_id then
      return false
    end
  end

  return true
end

function M.process_queue()
  if M.processor_status == "RUNNING" then
    return
  end

  M.processor_status = "RUNNING"

  while M.concurrency_count < M.MAX_CONCURRENCY and #M.queue > 0 do
    if state.need_compilation() and not vim.tbl_isempty(M.get_cmd().compile or {}) then
      local thread = M._compile()
      M.compile_status = { code = -1, err = "" }
      coroutine.resume(thread)
      actions.compilation_start()
      vim.wait(10000, function()
        return coroutine.status(thread) == "dead"
      end)
      actions.compilation_finish(M.compile_status)
    end

    if M.compile_status.code == 0 then
      state.set_by_key("need_compilation", function()
        return false
      end)
      M._execute(M.queue[1])
      M.concurrency_count = M.concurrency_count + 1
      table.remove(M.queue, 1)
      vim.wait(100)
    else
      break
    end
  end

  M.processor_status = "STOPPED"
end

function M.push_unique()
  local test_id = utils.get_current_line_number()

  if test_id == nil then
    return
  end

  if M.is_unique_test(test_id) then
    table.insert(M.queue, test_id)
  end

  M.process_queue()
end

function M.push_all()
  local tests = state.get_all_tests()

  for i = 1, #tests do
    if M.is_unique_test(i) then
      table.insert(M.queue, i)
    end
  end

  M.process_queue()
end

function M.create_test()
  state.set_by_key("tests", function(value)
    if value == nil then
      value = {}
    end

    table.insert(value, {})
    return value
  end)
  ui.render_home()
  state.write_all()
end

function M.remove_test()
  local test_id = utils.get_current_line_number()

  if not test_id then
    vim.notify("[ERROR]: Not a valid testcase to remove", vim.log.levels.ERROR)
    return
  end

  state.set_by_key("tests", function(value)
    table.remove(value, test_id)
    return value
  end)
  ui.render_home()
  state.write_all()
end

return M
