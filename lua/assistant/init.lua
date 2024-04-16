local receiver = require("assistant.receiver")
local runner = require("assistant.runner")
local ui = require("assistant.ui")

local execute_user_commands = function(arg)
	if arg.fargs[1] == "Receive" then
		receiver()
	elseif arg.fargs[1] == "RunTest" then
		runner()
	elseif arg.fargs[1] == "Toggle" then
		ui:toggle()
	else
		vim.notify("Invalid Argument", vim.log.levels.ERROR)
	end
end

return {
	setup = function()
		vim.api.nvim_create_user_command("Assistant", execute_user_commands, {
			nargs = 1,
			complete = function()
				return { "Receive", "RunTest", "Toggle" }
			end,
		})
	end,
}
