local state = require("assistant.ui.state")
local colors = require("assistant.ui.colors")
local buttons = require("assistant.ui.buttons")
local view = require("assistant.ui.view")
local api = require("assistant.api")
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
	view:home()

	vim.keymap.set("n", "H", function()
		buttons:navigate(1)
		view:home()
	end, { buffer = state.buf, silent = true, noremap = true })
	vim.keymap.set("n", "R", function()
		buttons:navigate(2)
		view:run()
	end, { buffer = state.buf, silent = true, noremap = true })
	vim.keymap.set("n", "A", function()
		buttons:navigate(3)
	end, { buffer = state.buf, silent = true, noremap = true })
	vim.keymap.set("n", "q", close_window, { buffer = state.buf, silent = true, noremap = true })
end

local function size(max, percent)
	return math.min(max, math.floor(max * percent))
end

local function get_window_config()
	return {
		relative = "editor",
		width = size(vim.o.columns, state.width),
		height = size(vim.o.lines, state.height),
		row = math.floor((vim.o.lines - size(vim.o.lines, state.height)) / 2),
		col = math.floor((vim.o.columns - size(vim.o.columns, state.width)) / 2),
		style = "minimal",
		focusable = false,
	}
end

local function create_window()
	if state.open then
		return
	end

	api:sync()
	colors:load()
	state.buf = vim.api.nvim_create_buf(false, true)
	state.win = vim.api.nvim_open_win(state.buf, true, get_window_config())
	state.open = true

	vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, {
		group = state.group,
		buffer = state.buf,
		callback = close_window,
	})

	vim.api.nvim_create_autocmd("VimResized", {
		group = state.group,
		callback = function()
			vim.api.nvim_win_set_config(state.win, get_window_config())
		end,
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
