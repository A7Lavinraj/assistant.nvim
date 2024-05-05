local api = require("assistant.api")
local config = require("assistant.config")
local runner = require("assistant.runner")
local Text = require("assistant.ui.text")
local AssistantView = {}

function AssistantView:home()
	local data = api:get()
	local text = Text:new()
	text:newline()

	if data then
		text:append(string.format("Name: %s", data.name), "Bold")
		text:newline()
		text:append(
			string.format("Time limit: %.2f seconds, Memory limit: %s MB", data.timeLimit / 1000, data.memoryLimit),
			"Comment"
		)
		text:newline()

		for _, test in ipairs(data.tests) do
			text:append("INPUT", "Boolean")
			text:append("----------", "Boolean")

			for _, value in ipairs(vim.split(test.input, "\n")) do
				text:append(value)
			end

			text:append("EXPECTED", "Boolean")
			text:append("----------", "Boolean")

			for _, value in ipairs(vim.split(test.output, "\n")) do
				text:append(value)
			end

			text:render()
			text:clear_text()
		end
	else
		text:append(" No sample file found for current buffer")
	end

	text:render()
end

local function interpolate(command)
	if not command then
		return nil
	end

	local function replace(filename)
		return filename
			:gsub("%$FILENAME_WITH_EXTENSION", api.RELATIVE_FILENAME_WITH_EXTENSION)
			:gsub("%$FILENAME_WITHOUT_EXTENSION", api.RELATIVE_FILENAME_WITHOUT_EXTENSION)
	end

	if command.main then
		command.main = replace(command.main)
	end

	if command.args then
		for i = 1, #command.args do
			command.args[i] = replace(command.args[i])
		end
	end

	return command
end

function AssistantView:run()
	local command = vim.deepcopy(config.config.commands[api.FILETYPE])

	command.compile = interpolate(command.compile)
	command.execute = interpolate(command.execute)

	local tests = api:get()["tests"]

	if tests then
		runner:run_all(tests, command)
	end
end

return AssistantView
