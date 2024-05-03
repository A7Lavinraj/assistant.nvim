local AssistantColors = {}

AssistantColors.colors = {
	AssistantButton = { link = "CursorLine" },
	AssistantButtonActive = { link = "IncSearch" },
}

function AssistantColors:load()
	for group, value in pairs(AssistantColors.colors) do
		vim.api.nvim_set_hl(0, group, { link = value.link, default = true })
	end
end

return AssistantColors
