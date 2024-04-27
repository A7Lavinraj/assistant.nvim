local utils = require("assistant.utils")
local M = {}
local sample_directory = string.format("%s/%s/", vim.fn.expand("%:p:h"), ".ast")

---@param chunk string
local function store_problem(chunk)
	if vim.fn.isdirectory(".ast") == 0 then
		vim.fn.mkdir(".ast")
	end

	local data = string.match(chunk, "^.+\r\n(.+)$")
	local filename = utils.filter_filename(vim.json.decode(data)["name"])

	if filename then
		local problem = io.open(sample_directory .. filename, "w")

		if problem then
			problem:write(tostring(data))
		end
	end
end

M.setup = function()
	local server = vim.uv.new_tcp()

	server:bind("127.0.0.1", 10043)
	server:listen(128, function(listening_error)
		assert(not listening_error, listening_error)
		local client = vim.uv.new_tcp()
		server:accept(client)
		client:read_start(function(read_error, chunk)
			assert(not read_error, read_error)

			if chunk then
				vim.schedule(function()
					store_problem(chunk)
				end)
			else
				client:shutdown()
				client:close()
			end
		end)
	end)

	vim.uv.run()
end

return M
