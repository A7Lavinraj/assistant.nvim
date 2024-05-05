local state = require("assistant.ui.state")

---@class AssistantText
local AssistantText = {}
AssistantText.__index = AssistantText

function AssistantText:new()
	return setmetatable({
		lines = {},
	}, AssistantText)
end

function AssistantText:newline()
	table.insert(self.lines, { content = "", hl_group = "NonText" })
end

function AssistantText:append(text, hl_group)
	table.insert(self.lines, { content = string.rep(" ", 2) .. text, hl_group = hl_group or "AerialNormal" })
end

function AssistantText:clear_screen()
	vim.api.nvim_buf_set_lines(state.buf, 2, -1, false, {})
end

function AssistantText:clear_text()
	self.lines = {}
end

function AssistantText:render()
	for _, line in ipairs(self.lines) do
		if vim.api.nvim_buf_is_valid(state.buf) then
			vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, { line.content })
			vim.api.nvim_buf_add_highlight(
				state.buf,
				-1,
				line.hl_group,
				vim.api.nvim_buf_line_count(state.buf) - 1,
				2,
				-1
			)
		end
	end
end

return AssistantText
