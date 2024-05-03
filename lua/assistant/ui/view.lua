local api = require("assistant.api")
local state = require("assistant.ui.state")
local config = require("assistant.config")
local runner = require("assistant.runner")
local Text = require("assistant.ui.text")
local AssistantView = {}

function AssistantView:home()
	local data = api:get()
	local text = Text:new()
	text:newline()

	if data then
		text:append(string.format("Name: %s", data.name))
		text:newline()
		text:append(
			string.format("Time limit: %.2f seconds, Memory limit: %s MB", data.timeLimit / 1000, data.memoryLimit)
		)
		text:newline()

		text:append("INPUT")
		text:append("----------")

		for _, test in ipairs(data.tests) do
			for _, value in ipairs(vim.split(test.input, "\n")) do
				text:append(value)
			end
		end

		text:append("EXPECTED")
		text:append("----------")

		for _, test in ipairs(data.tests) do
			for _, value in ipairs(vim.split(test.output, "\n")) do
				text:append(value)
			end
		end
	else
		text:append(" No sample file found for current buffer")
	end

	vim.api.nvim_buf_set_lines(state.buf, 2, -1, false, text.content)
end

function AssistantView:run()
	local command = config.config.commands[api.FILETYPE] or {}

	local compile = table.concat(command.compile, " ")
	local execute = table.concat(command.execute, " ")

	compile = compile:gsub("%$FILENAME_WITH_EXTENSION", api.ABSOLUTE_FILENAME_WITH_EXTENSION)
	compile = compile:gsub("%$FILENAME_WITHOUT_EXTENSION", api.ABSOLUTE_FILENAME_WITHOUT_EXTENSION)
	execute = execute:gsub("%$FILENAME_WITH_EXTENSION", api.RELATIVE_FILENAME_WITH_EXTENSION)
	execute = execute:gsub("%$FILENAME_WITHOUT_EXTENSION", api.RELATIVE_FILENAME_WITHOUT_EXTENSION)

	command.compile = vim.split(compile, " ")
	command.execute = vim.split(execute, " ")

	local tests = api:get()["tests"]

	if tests then
		runner:run_all(tests, command)
	end
end

return AssistantView
