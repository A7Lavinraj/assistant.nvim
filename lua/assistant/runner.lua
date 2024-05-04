local Text = require("assistant.ui.text")
local state = require("assistant.ui.state")
local config = require("assistant.config").config

---@class AssistantRunner
local AssistantRunner = {}
AssistantRunner.__index = AssistantRunner

local function setTimeout(delay, callback)
	local co = coroutine.create(function()
		vim.defer_fn(callback, delay)
	end)
	coroutine.resume(co)
end

function AssistantRunner:run(command, testcase, callback)
	local job_id = vim.fn.jobstart(command, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				testcase.stdout = data
			end
		end,
		on_stderr = function(_, data)
			if data then
				testcase.stderr = data
			end
		end,
		on_exit = function(_, code)
			testcase.status_code = code
			callback(testcase)
		end,
	})

	setTimeout(config.time_limit, function()
		local id = vim.fn.jobstop(job_id)

		if id == 1 then
			testcase.killed = true
		end
	end)

	vim.api.nvim_chan_send(job_id, testcase.input)
end

function AssistantRunner:compile(command, callback)
	local result = { status_code = 0 }

	if command then
		vim.fn.jobstart(command, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = function(_, data)
				if data then
					result.stdout = data
				end
			end,
			on_stderr = function(_, data)
				if data then
					result.stderr = data
				end
			end,
			on_exit = function(_, code)
				result.status_code = code
				callback(result)
			end,
		})
	else
		callback(result)
	end
end

function AssistantRunner:run_all(testcases, command)
	self:compile(command.compile, function(compile_status)
		if compile_status.status_code == 0 then
			local text = Text:new()
			text:newline()

			if vim.api.nvim_buf_is_valid(state.buf) then
				vim.api.nvim_buf_set_lines(state.buf, 2, -1, false, {})
			end

			for _, testcase in ipairs(testcases) do
				self:run(command.execute, testcase, function(execute_status)
					if execute_status.killed then
						text:append("TIME LIMIT EXCEEDED")
					else
						text:append("INPUT")
						text:append("----------")

						for _, value in ipairs(vim.split(testcase.input, "\n")) do
							text:append(value)
						end

						text:append("EXPECTED")
						text:append("----------")

						for _, value in ipairs(vim.split(testcase.output, "\n")) do
							text:append(value)
						end

						text:append("STDOUT")
						text:append("----------")

						for _, value in ipairs(execute_status.stdout) do
							text:append(value)
						end
					end

					if vim.api.nvim_buf_is_valid(state.buf) then
						vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, text.content)
					end
				end)
			end
		else
			local text = Text:new()
			text:newline()

			for _, value in ipairs(compile_status.stderr) do
				text:append(value)
			end

			if vim.api.nvim_buf_is_valid(state.buf) then
				vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, text.content)
			end
		end
	end)
end

return AssistantRunner
