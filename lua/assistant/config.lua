local M = {}

M.config = {
	commands = {},
	time_limit = 5000,
}

M.update = function(opts)
	M.config.commands = opts.commands or {}
	M.config.time_limit = opts.time_limit or 5000
end

return M
