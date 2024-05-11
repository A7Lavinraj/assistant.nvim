local AssistantRunner = {}

function AssistantRunner.new()
  local self = setmetatable({}, { __index = AssistantRunner })

  self.tests = {}
  self.command = nil
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

function AssistantRunner:comparator(stdout, expected)
  local function process_str(str)
    return str:gsub("\n", " "):gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")
  end

  return process_str(stdout) == process_str(expected)
end

function AssistantRunner:compile(callback)
  if self.command.compile then
    _, _ = vim.uv.spawn(self.command.compile.main, { args = self.command.compile.args }, callback)
  else
    callback(0, 0)
  end
end

function AssistantRunner:run(index)
  local process = {
    stdin = vim.uv.new_pipe(),
    stdout = vim.uv.new_pipe(),
    stderr = vim.uv.new_pipe(),
  }

  process.handle, process.id = vim.uv.spawn(
    self.command.execute.main,
    { args = self.command.execute.args, stdio = { process.stdin, process.stdout, process.stderr } },
    function(code, signal)
      process.code, process.signal = code, signal

      if process.code == 0 then
        if self:comparator(self.tests[index].stdout, self.tests[index].output) then
          self.tests[index].status = "PASSED"
          self.tests[index].group = "AssistantPassed"
        else
          self.tests[index].status = "FAILED"
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
    end
  )

  self.tests[index].status = "RUNNING"
  self.tests[index].group = "AssistantRunning"
  self.exe_cb(self.tests)

  local timer = vim.uv.new_timer()
  timer:start(self.time_limit, 0, function()
    timer:stop()
    timer:close()

    if self.tests[index].status == "RUNNING" then
      self.tests[index].status = "TIME LIMIT EXCEEDED"
      self.tests[index].group = "AssistantKilled"
      self.exe_cb(self.tests)
    end
  end)

  vim.uv.read_start(process.stdout, function(err, data)
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

  vim.uv.read_start(process.stderr, function(err, data)
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

  vim.uv.write(process.stdin, self.tests[index].input)
  vim.uv.shutdown(process.stdin)
end

function AssistantRunner:run_all()
  self:compile(function(code, signal)
    if code == 0 then
      for i = 1, #self.tests do
        self:run(i)
      end
    else
      self.cmp_cb(code, signal)
    end
  end)
end

return AssistantRunner
