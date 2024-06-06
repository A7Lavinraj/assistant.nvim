---@class AssistantRunner
local AssistantRunner = {}

function AssistantRunner.new()
  local self = setmetatable({}, { __index = AssistantRunner })

  self.tests = nil
  self.command = nil
  self.time_limit = nil
  self.cmp_cb = nil
  self.exe_cb = nil

  return self
end

function AssistantRunner:init(opts)
  self.tests = opts.tests
  self.command = opts.command
  self.time_limit = opts.time_limit
  self.cmp_cb = opts.cmp_cb
  self.exe_cb = opts.exe_cb
end

local function comparator(stdout, expected)
  local function process_str(str)
    return (str or ""):gsub("\n", " "):gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")
  end

  return process_str(stdout) == process_str(expected)
end

function AssistantRunner:compile(callback)
  if not (self.command and self.command.compile) then
    callback(0, {})
    return
  end

  local process = { cmd = vim.deepcopy(self.command.compile.args) }

  table.insert(process.cmd, 1, self.command.compile.main)
  vim.fn.jobstart(process.cmd, {
    stderr_buffered = true,
    on_stderr = function(_, data)
      process.stderr = data
    end,
    on_exit = function(_, code)
      callback(code, process.stderr)
    end,
  })
end

function AssistantRunner:run(index)
  local process = {
    stdin = vim.loop.new_pipe(),
    stdout = vim.loop.new_pipe(),
    stderr = vim.loop.new_pipe(),
    timer = vim.loop.new_timer(),
  }

  if not (self.command and self.command.execute) then
    return
  end

  process.handle, process.id = vim.loop.spawn(
    self.command.execute.main,
    { args = self.command.execute.args, stdio = { process.stdin, process.stdout, process.stderr } },
    function(code, signal)
      process.code, process.signal = code, signal

      if process.code == 0 then
        if comparator(self.tests[index].stdout, self.tests[index].output) then
          self.tests[index].status = "PASSED"
          self.tests[index].group = "AssistantPassed"
        else
          self.tests[index].status = "FAILED"
          self.tests[index].expand = true
          self.tests[index].group = "AssistantFailed"
        end

        self.exe_cb(self.tests)
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

      self.tests[index].end_at = vim.loop.now()
    end
  )

  self.tests[index].status = "RUNNING"
  self.tests[index].group = "AssistantRunning"
  self.tests[index].start_at = vim.loop.now()
  self.exe_cb(self.tests)

  process.timer:start(self.time_limit, 0, function()
    if not process.timer:is_active() then
      process.timer:stop()
    end

    if not process.timer:is_closing() then
      process.timer:close()
    end

    self.tests[index].end_at = vim.loop.now()

    if self.tests[index].status == "RUNNING" then
      self.tests[index].status = "TIME LIMIT EXCEEDED"
      self.tests[index].group = "AssistantKilled"
      self.exe_cb(self.tests)
    end
  end)

  vim.loop.read_start(process.stdout, function(err, data)
    if err or not data then
      if process.stdout:is_readable() then
        process.stdout:read_stop()
      end

      if process.stdout:is_closing() then
        process.stdout:close()
      end
    else
      self.tests[index].stdout = data
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
      self.tests[index].stderr = data
    end
  end)

  vim.loop.write(process.stdin, self.tests[index].input)
  vim.loop.shutdown(process.stdin)
end

function AssistantRunner:run_unique(index)
  self:compile(function(code, stderr)
    if code == 0 then
      self:run(index)
    else
      self.cmp_cb(code, stderr)
    end
  end)
end

function AssistantRunner:run_all()
  self:compile(function(code, stderr)
    if code == 0 then
      for i = 1, #(self.tests or {}) do
        self:run(i)
      end
    else
      self.cmp_cb(code, stderr)
    end
  end)
end

return AssistantRunner
