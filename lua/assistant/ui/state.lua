---@class AssistantState
local AssistantState = {
	buf = nil,
	win = nil,
	height = 0.8,
	width = 0.6,
	open = false,
	group = vim.api.nvim_create_augroup("AssistantGroup", { clear = true }),
}

return AssistantState
