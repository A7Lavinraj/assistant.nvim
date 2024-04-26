---@type AssistantState
local AssistantState = {
	buf = nil,
	win = nil,
	height = vim.o.lines,
	width = vim.o.columns,
	open = false,
	group = vim.api.nvim_create_augroup("AssistantGroup", { clear = true }),
}

return AssistantState
