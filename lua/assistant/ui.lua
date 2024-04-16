---@class UI
---@field state boolean
---@field buf_id number
---@field win_id number
---@field source_id number
local SplitWindow = {}
SplitWindow.__index = SplitWindow

function SplitWindow.new()
	return setmetatable({
		state = false,
		buf_id = nil,
		win_id = nil,
	}, SplitWindow)
end

function SplitWindow:open()
	if not self.state then
		self.source_id = vim.api.nvim_get_current_win()
		vim.cmd("40vsplit Assistant")
		self.buf_id = vim.api.nvim_get_current_buf()
		self.win_id = vim.api.nvim_get_current_win()

		-- setting split window options
		vim.api.nvim_set_option_value("number", false, { win = self.win_id })
		vim.api.nvim_set_option_value("relativenumber", false, { win = self.win_id })
		vim.api.nvim_set_option_value("foldenable", false, { win = self.win_id })
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = self.buf_id })
		vim.api.nvim_set_option_value("buflisted", false, { buf = self.buf_id })

		self.state = true
	end
end

function SplitWindow:close()
	if self.state then
		vim.api.nvim_buf_delete(self.buf_id, { force = true })

		self.buf_id = nil
		self.state = false
	end
end

function SplitWindow:toggle()
	if self.state then
		self:close()
	else
		self:open()
	end
end

function SplitWindow:render(expected, output, verdict)
	self:open()
	vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, { "Assistant.nvim", "" })

	if expected then
		vim.api.nvim_buf_set_lines(
			self.buf_id,
			-1,
			-1,
			false,
			vim.tbl_flatten({ "EXPECTED:", "---------------", vim.split(expected, "\n") })
		)
	end

	if output then
		vim.api.nvim_buf_set_lines(
			self.buf_id,
			-1,
			-1,
			false,
			vim.tbl_flatten({ "OUTPUT:", "---------------", vim.split(output, "\n") })
		)
	end
	vim.api.nvim_buf_set_lines(self.buf_id, -1, -1, false, { "VERDICT: " .. verdict })
end

return SplitWindow:new()
