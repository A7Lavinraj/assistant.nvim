local receiver = require("assistant.receiver")
local runner = require("assistant.runner")
local ui = require("assistant.ui")

return {
	setup = function()
		vim.api.nvim_create_user_command("AssistantRecieve", receiver, {
			nargs = 0,
		})
		vim.api.nvim_create_user_command("AssistantRuntest", runner, {
			nargs = 0,
		})
		vim.api.nvim_create_user_command("AssistantToggle", function()
			ui:toggle()
		end, {
			nargs = 0,
		})
	end,
}
