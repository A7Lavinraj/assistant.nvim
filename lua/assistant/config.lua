local M = {}

M.config = {
	commands = {},
}

M.update = function(opts)
	M.config.commands = opts.commands or {}
end

return M
