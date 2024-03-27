local M = {}

--- @return table
local get_sources = function()
	local sources = {}
	local options = {
		"gcc",
		"g++",
		"python",
		"python3",
		"rustc",
	}

	for _, value in ipairs(options) do
		local source = io.popen(value .. " --version")

		if source then
			table.insert(sources, value)
		end
	end

	return sources
end

--- @param data table: The data received from the client
--- @param path string: The path where files will be created
local create_source = function(data, path)
	local sources = get_sources()

	vim.ui.select(sources, { prompt = "Select source language" }, function(choice)
		if choice == "cpp" then
			vim.cmd("e " .. path .. string.gsub(data["name"], " ", "_") .. ".cpp | w")
		elseif choice == "gcc" then
			vim.cmd("e " .. path .. string.gsub(data["name"], " ", "_") .. ".c | w")
		elseif choice == "python" or choice == "python3" then
			vim.cmd("e " .. path .. string.gsub(data["name"], " ", "_") .. ".py | w")
		elseif choice == "rustc" then
			vim.cmd("e " .. path .. string.gsub(data["name"], " ", "_") .. ".rs | w")
		else
			vim.notify("Selection Aborted", 3) -- nothing get selected
		end
	end)
end

--- @param data table: The data received from the client
--- @param path string: The path where files will be created
local create_samples = function(data, path)
	for index, value in ipairs(data["tests"]) do
		local input_file = io.open(path .. string.gsub(data["name"], " ", "_") .. string.format("-%d.in", index), "w")
		local output_file = io.open(path .. string.gsub(data["name"], " ", "_") .. string.format("-%d.exp", index), "w")

		if input_file then
			input_file:write(value["input"])
		else
			vim.notify("Something went wrong with input file", 3)
		end

		if output_file then
			output_file:write(value["output"])
		else
			vim.notify("Something went wrong with output file", 3)
		end
	end
end

local receive = function()
	local data = {}
	local path = vim.loop.cwd() .. "/" .. vim.fn.expand("%:h") .. "/"
	local server = vim.loop.new_tcp()
	local client = vim.loop.new_tcp()
	local timer = vim.loop.new_timer()
	local function stop_receiving()
		if client and not client:is_closing() then
			client:shutdown()
			client:close()
		end
		if server and not server:is_closing() then
			server:shutdown()
			server:close()
		end
		if timer and not timer:is_closing() then
			timer:stop()
			timer:close()
		end
	end

	server:bind("127.0.0.1", 10043)
	server:listen(128, function(listen_err)
		if not listen_err then -- handling listening error
			server:accept(client)
			client:read_start(function(read_err, chunk)
				if not read_err then -- handling reading error
					if chunk then
						table.insert(data, chunk)
					else
						data = string.match(table.concat(data), "^.+\r\n(.+)$")
						data = vim.json.decode(data) -- parsing stringify json
						create_samples(data, path) -- creating sample files
						stop_receiving() -- stoping server

						vim.schedule(function()
							create_source(data, path) -- scheduling the creation of source code file
						end)
					end
				else
					vim.notify("Something went wrong, try again", vim.log.levels.ERROR)
				end
			end)
		else
			vim.notify("Something went wrong, try again", vim.log.levels.ERROR)
		end
	end)

	timer = vim.loop.new_timer() -- handling idealness
	timer:start(100000, 0, stop_receiving)

	if vim.notify then
		vim.notify("Assistant is ready", 2) -- informing that assistant is ready to fetch samples
	end
end

M.setup = function()
	vim.api.nvim_create_user_command("Assistant", receive, { nargs = 0 })
end

return M
