local Text = require("assistant.ui.text")
local config = require("assistant.config")

---@class AssistantRunner
local AssistantRunner = {}
AssistantRunner.__index = AssistantRunner

local function run(command, testcase, callback)
  ---@diagnostic disable: undefined-field
  local stdin = vim.uv.new_pipe()
  local stdout = vim.uv.new_pipe()
  local stderr = vim.uv.new_pipe()
  local tbl = {}

  local handle, _ = vim.uv.spawn(
    command.main,
    { args = command.args, stdio = { stdin, stdout, stderr } },
    function(code, _)
      if code == 0 then
        tbl.status = "FINISHED"
        callback(tbl)
      end
    end
  )

  tbl.status = "RUNNING"

  local timer = vim.uv.new_timer()
  timer:start(config.config.time_limit, 0, function()
    timer:stop()
    timer:close()
    handle:close()

    if tbl.status == "RUNNING" then
      tbl.killed = true
      callback(tbl)
    end
  end)

  vim.uv.read_start(stdout, function(_, data)
    if data then
      tbl.stdout = data
    end
  end)

  vim.uv.read_start(stderr, function(_, data)
    if data then
      tbl.stderr = data
    end
  end)

  vim.uv.write(stdin, testcase.input)
end

local function compile(command, callback)
  local _, _ = vim.uv.spawn(command.main, { args = command.args }, callback)
end

local function comparator(stdout, expected)
  local function process_str(str)
    return str:gsub("\n", " "):gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")
  end

  return process_str(stdout) == process_str(expected)
end

function AssistantRunner:run_all(testcases, command)
  local text = Text:new()

  text:newline()
  text:append(" COMPILING... ", "DiagnosticVirtualTextINFO")
  text:render()
  text:clear_text()

  compile(command.compile, function(compile_code, _)
    vim.schedule(function()
      text:clear_screen()
      text:newline()
      text:append(" RUNNING... ", "DiagnosticVirtualTextINFO")
      text:render()
      text:clear_text()
    end)

    if compile_code == 0 then
      for index, testcase in ipairs(testcases) do
        run(command.execute, testcase, function(execution_result)
          text:newline()

          if execution_result.killed then
            text:append(
              string.format(" Testcase #%d TIME LIMIT EXCEEDED ", index),
              "DiagnosticVirtualTextWARN"
            )
          else
            if comparator(execution_result.stdout, testcase.output) then
              text:append(string.format(" Testcase #%d PASSED ", index), "DiagnosticVirtualTextHINT")
            else
              text:append(string.format(" Testcase #%d FAILED ", index), "DiagnosticVirtualTextERROR")
            end
          end

          vim.schedule(function()
            text:clear_screen()
            text:render()
          end)
        end)
      end
    end
  end)
end

return AssistantRunner
