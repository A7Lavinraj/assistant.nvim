local state = require("assistant.ui.state")
local buttons = require("assistant.ui.buttons")
local AssistantWindow = {}

local function close_window()
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(state.win) then
			vim.api.nvim_win_close(state.win, true)
			state.win = -1
		end

		if vim.api.nvim_buf_is_valid(state.buf) then
			vim.api.nvim_buf_delete(state.buf, { force = true })
			state.buf = -1
		end

		state.open = false
	end)
end

local function render()
	buttons:init({
		padding = 3,
		gap = 3,
		buttons = {
			{ name = "󰟍 Assistant.nvim(H)", active = true },
			{ name = " Run Test(R)", active = false },
			{ name = " Add Test(A)", active = false },
		},
	})
	buttons:render()

	vim.keymap.set("n", "H", function()
		buttons:navigate(1)
	end, { buffer = state.buf, silent = true, noremap = true })
	vim.keymap.set("n", "R", function()
		buttons:navigate(2)
	end, { buffer = state.buf, silent = true, noremap = true })
	vim.keymap.set("n", "A", function()
		buttons:navigate(3)
	end, { buffer = state.buf, silent = true, noremap = true })
	vim.keymap.set("n", "q", close_window, { buffer = state.buf, silent = true, noremap = true })
end

local function create_window()
	if state.open then
		return
	end

	state.buf = vim.api.nvim_create_buf(false, true)
	state.win = vim.api.nvim_open_win(state.buf, true, {
		relative = "editor",
		width = state.width - 60,
		height = state.height - 8,
		row = 4,
		col = 30,
		style = "minimal",
	})
	state.open = true

	vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, {
		group = state.group,
		buffer = state.buf,
		callback = close_window,
	})

	render()
end

function AssistantWindow.toggle()
	if state.open then
		close_window()
	else
		create_window()
	end
end

return AssistantWindow
