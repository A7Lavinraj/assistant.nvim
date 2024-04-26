local M = {}

M.colors = {
	AssistantButton = { link = "CursorLine" },
	AssistantButtonActive = { link = "IncSearch" },
}

M.load_colors = function()
	for group, value in pairs(M.colors) do
		vim.api.nvim_set_hl(0, group, { link = value.link, default = true })
	end
end

return M
