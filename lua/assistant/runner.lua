local Text = require("assistant.ui.text")
local state = require("assistant.ui.state")

---@class AssistantRunner
local AssistantRunner = {}
AssistantRunner.__index = AssistantRunner

local function setTimeout(delay, callback)
	local co = coroutine.create(function()
		vim.defer_fn(callback, delay)
	end)
	coroutine.resume(co)
end

local function run(command, testcase, callback)
	---@diagnostic disable: undefined-field
	local stdin = vim.uv.new_pipe()
	local stdout = vim.uv.new_pipe()
	local stderr = vim.uv.new_pipe()
	local tbl = {}

	local _, _ = vim.uv.spawn(
		command.main,
		{ args = command.args, stdio = { stdin, stdout, stderr } },
		function(code, _)
			if code == 0 then
				callback(tbl)
			end
		end
	)

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

	compile(command.compile, function(compile_code, _)
		if compile_code == 0 then
			for index, testcase in ipairs(testcases) do
				run(command.execute, testcase, function(execution_result)
					text:newline()

					if comparator(execution_result.stdout, testcase.output) then
						text:append(string.format(" Testcase #%d PASSED ", index), "DiagnosticVirtualTextHINT")
					else
						text:append(string.format(" Testcase #%d FAILED ", index), "DiagnosticVirtualTextERROR")
					end

					vim.schedule(function()
						text:render()
						text:clear()
					end)
				end)
			end
		end
	end)
end

return AssistantRunner
