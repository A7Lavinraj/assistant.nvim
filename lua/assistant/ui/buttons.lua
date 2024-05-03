local state = require("assistant.ui.state")

---@class RadioButtons
local Buttons = {}

---@param config ButtonsConfig
function Buttons:init(config)
	local text = ""

	for index, button in ipairs(config.buttons) do
		text = text .. button.name .. (index == #config.buttons and "" or string.rep(" ", config.gap))
	end

	self.text = text
	self.gap = config.gap
	self.padding = config.padding
	self.buttons = config.buttons
end

function Buttons:render()
	vim.api.nvim_buf_set_lines(
		state.buf,
		1,
		-1,
		false,
		{ string.rep(" ", self.padding) .. self.text .. string.rep(" ", self.padding) }
	)

	Buttons:highlights()
end

function Buttons:highlights()
	local start_col = self.padding

	for _, button in pairs(self.buttons) do
		vim.api.nvim_buf_add_highlight(
			state.buf,
			-1,
			button.active and "AssistantButtonActive" or "AssistantButton",
			1,
			start_col - 1,
			start_col + #button.name + 1
		)
		start_col = start_col + #button.name + self.gap
	end
end

---@param index number
function Buttons:navigate(index)
	for i = 1, #self.buttons do
		self.buttons[i].active = false
	end

	self.buttons[index].active = true

	Buttons:render()
end

return Buttons
