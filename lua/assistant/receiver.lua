local generator = require("assistant.generator")

---@return nil
local receiver = function()
	local data = {}
	local path = vim.fn.expand("%:p:h")
	local server = vim.loop.new_tcp()
	local client = vim.loop.new_tcp()
	local timer = vim.loop.new_timer()

	---@return nil
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
						generator.store_problem(data, path) -- creating problem file
						stop_receiving() -- stoping server

						vim.schedule(function()
							generator.generate_source(data, path) -- scheduling the creation of source code file
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
		vim.notify("Assistant is ready", vim.log.levels.INFO) -- informing that assistant is ready to fetch samples
	end
end

return receiver
