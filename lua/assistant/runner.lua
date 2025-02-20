-- local actions = require("assistant.core.actions")
local opts = require("assistant.config").opts
local state = require("assistant.state")
local utils = require("assistant.utils")
local luv = vim.uv or vim.loop

local AstRunner = {}

function AstRunner.new()
  local self = setmetatable({}, { __index = AstRunner })

  self:_init()

  return self
end

function AstRunner:_init()
  self.queue = {}
  self.MAX_CONCURRENCY = 5
  self.concurrency_count = 0
  self.processor_status = "STOPPED"
  self.compile_status = { code = 0, err = "" }
  self.budget = opts.core.process_budget or 5000
  self.status_map = {
    AC = { text = "accepted", hl = "AstTextGreen" },
    WA = { text = "wrong answer", hl = "AstTextRed" },
    TLE = { text = "time limit exceeded", hl = "AstTextYellow" },
    RE = { text = "runtime error", hl = "AstTextYellow" },
    CE = { text = "compilation error", hl = "AstTextYellow" },
    SKIP = { text = "skipped", hl = "AstTextP" },
    RUN = { text = "running", hl = "AstTextYellow" },
    QUEUE = { text = "queued", hl = "AstTextBlue" },
  }
end

function AstRunner:get_cmd()
  local cmd = vim.deepcopy(opts.commands[state.get_src_ft()] or {}) ---@type Ast.Config.Command.Opts

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
function AstRunner:_execute(test_id)
  local cmd = self:get_cmd()
  local process = {}
  local test = state.get_test_by_id(test_id)

  process.stdio = { luv.new_pipe(false), luv.new_pipe(false), luv.new_pipe(false) }
  process.timer = luv.new_timer()
  process.stdout = ""
  process.stderr = ""

  if not cmd.execute then
    return
  end

  process.handle, process.pid = luv.spawn(
    cmd.execute.main,
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
        if (process.end_at - process.start_at) > self.budget then
          state.set_by_key("tests", function(value)
            value[test_id].stdout = process.stdout
            value[test_id].stderr = process.stderr
            value[test_id].status = self.status_map.TLE
            value[test_id].time_taken = (process.end_at - process.start_at) * 0.001

            return value
          end)

          state.write_all()
        elseif utils.compare(process.stdout, test.output) then
          state.set_by_key("tests", function(value)
            value[test_id].stdout = process.stdout
            value[test_id].stderr = process.stderr
            value[test_id].status = self.status_map.AC
            value[test_id].time_taken = (process.end_at - process.start_at) * 0.001

            return value
          end)

          state.write_all()
        else
          state.set_by_key("tests", function(value)
            value[test_id].stdout = process.stdout
            value[test_id].stderr = process.stderr
            value[test_id].status = self.status_map.WA
            value[test_id].time_taken = (process.end_at - process.start_at) * 0.001

            return value
          end)

          state.write_all()
        end
      else
        state.set_by_key("tests", function(value)
          value[test_id].stdout = process.stdout
          value[test_id].stderr = process.stderr
          value[test_id].status = self.status_map.RE
          value[test_id].time_taken = (process.end_at - process.start_at) / 1e3

          return value
        end)

        state.write_all()
      end

      self.concurrency_count = self.concurrency_count - 1
      self:process_queue()

      vim.schedule(function()
        self:render_tasks()
      end)

      -- actions.execution_status()
    end
  )

  if not process.handle then
    utils.notify_err("[Process]: unable to start execution")

    for _, pipe in ipairs(process.stdio) do
      pipe:close()
    end
  end

  process.start_at = luv.now()
  state.set_by_key("tests", function(value)
    value[test_id].status = self.status_map.RUN
    return value
  end)

  vim.schedule(function()
    self:render_tasks()
  end)

  process.timer:start(self.budget, 0, function()
    if not process.timer:is_closing() then
      process.timer:close()
    end

    if process.handle and process.handle:is_active() then
      luv.kill(process.pid, 15)
    end

    state.set_by_key("tests", function(value)
      value[test_id].status = self.status_map.TLE
      return value
    end)

    vim.schedule(function()
      self:render_tasks()
    end)
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
function AstRunner:_compile()
  ---@type thread
  local thread = nil
  thread = coroutine.create(function()
    local cmd = self:get_cmd()
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

        self.compile_status.code = code
        self.compile_status.err = process.stderr

        coroutine.resume(thread)
      end
    )
    if not process.handle then
      utils.notify_err("unable to start compilation")

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
function AstRunner:is_unique_test(test_id)
  for i = 1, #self.queue do
    if self.queue[i] == test_id then
      return false
    end
  end

  return true
end

function AstRunner:process_queue()
  if self.processor_status == "RUNNING" then
    return
  end

  self.processor_status = "RUNNING"

  while self.concurrency_count < self.MAX_CONCURRENCY and #self.queue > 0 do
    if state.need_compilation() and not vim.tbl_isempty(self:get_cmd().compile or {}) then
      local thread = self:_compile()
      self.compile_status = { code = -1, err = "" }
      coroutine.resume(thread)
      -- actions.compilation_start()
      vim.wait(10000, function()
        return coroutine.status(thread) == "dead"
      end)
      -- actions.compilation_finish(M.compile_status)
    end

    if self.compile_status.code == 0 then
      state.set_by_key("need_compilation", function()
        return false
      end)
      self:_execute(self.queue[1])
      self.concurrency_count = self.concurrency_count + 1
      table.remove(self.queue, 1)
      vim.wait(100)
    else
      break
    end
  end

  self.processor_status = "STOPPED"
end

function AstRunner:push_unique()
  local test_id = utils.get_current_line_number()

  if test_id == nil then
    return
  end

  if self:is_unique_test(test_id) then
    table.insert(self.queue, test_id)
  end

  state.set_by_key("tests", function(value)
    value[test_id].status = self.status_map.QUEUE
    return value
  end)

  self:render_tasks()
  self:process_queue()
end

function AstRunner:push_all()
  local tests = state.get_all_tests()

  for i = 1, #tests do
    if self:is_unique_test(i) then
      table.insert(self.queue, i)
    end
  end

  state.set_by_key("tests", function(value)
    for i = 1, #value do
      value[i].status = self.status_map.QUEUE
    end

    return value
  end)

  self:render_tasks()
  self:process_queue()
end

function AstRunner:create_test()
  state.set_by_key("tests", function(value)
    if value == nil then
      value = {}
    end

    table.insert(value, {
      input = "",
      output = "",
      expected = "",
    })

    return value
  end)

  self:render_tasks()
  state.write_all()
end

function AstRunner:remove_test()
  local test_id = utils.get_current_line_number()

  if not test_id then
    utils.notify_err("[ERROR]: Not a valid testcase to remove")
    return
  end

  state.set_by_key("tests", function(value)
    table.remove(value, test_id)
    return value
  end)

  self:render_tasks()
  state.write_all()
end

return AstRunner
