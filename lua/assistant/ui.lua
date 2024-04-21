---@class Window
---@field state boolean
---@field bufnr number
---@field winid number
---@field width number
---@field height number
---@field source string
---@field filetype string
local Window = {}
Window.__index = Window

function Window:new()
	return setmetatable({
		state = false,
		bufnr = nil,
		winid = nil,
		width = math.max(math.floor(vim.o.columns / 2), 50),
		height = math.max(math.floor(vim.o.lines / 2), 30),
	}, Window)
end

function Window:open()
	if not self.state then
		self.bufnr = vim.api.nvim_create_buf(false, true)
		self.winid = vim.api.nvim_open_win(self.bufnr, true, {
			relative = "editor",
			width = self.width,
			height = self.height,
			row = 5,
			col = math.floor(self.width / 2),
			style = "minimal",
			border = "rounded",
			title = "Assistant",
			title_pos = "center",
		})

		self.state = true
	end
end

function Window:close()
	if vim.api.nvim_win_is_valid(self.winid) then
		vim.api.nvim_win_close(self.winid, true)
		self.winid = nil
	end

	if vim.api.nvim_buf_is_valid(self.bufnr) then
		vim.api.nvim_buf_delete(self.bufnr, { force = true })
	end

	self.state = false
	self.bufnr = nil
	self.winid = nil
end

function Window:toggle()
	if self.state then
		self:close()
	else
		self:open()
	end
end

---@param input string | nil
---@param expected string | nil
---@param output string | nil
---@param verdict string | nil
---@param error? table | nil
function Window:render(input, expected, output, verdict, error)
	if error then
		vim.api.nvim_buf_set_lines(
			self.bufnr,
			-1,
			-1,
			false,
			vim.tbl_flatten({ vim.split(table.concat(error, "\n"), "\n") })
		)
	end

	if input then
		vim.api.nvim_buf_set_lines(
			self.bufnr,
			-1,
			-1,
			false,
			vim.tbl_flatten({ "INPUT:", "---------------", vim.split(input, "\n") })
		)
	end

	if expected then
		vim.api.nvim_buf_set_lines(
			self.bufnr,
			-1,
			-1,
			false,
			vim.tbl_flatten({ "EXPECTED:", "---------------", vim.split(expected, "\n") })
		)
	end

	if output then
		vim.api.nvim_buf_set_lines(
			self.bufnr,
			-1,
			-1,
			false,
			vim.tbl_flatten({ "OUTPUT:", "---------------", vim.split(output, "\n") })
		)
	end

	if verdict then
		vim.api.nvim_buf_set_lines(
			self.bufnr,
			-1,
			-1,
			false,
			{ "---------------", "VERDICT: " .. verdict, "---------------" }
		)
	end

	vim.api.nvim_win_set_cursor(self.winid, { vim.api.nvim_buf_line_count(self.bufnr), 0 })
end

local global_instance = Window:new()

vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("Assistant", { clear = true }),
	buffer = global_instance.bufnr,
	callback = function()
		if vim.bo.filetype ~= "" then
			global_instance.source = vim.fn.expand("%:p:r")
			global_instance.filetype = vim.bo.filetype
		end
	end,
})

return global_instance
