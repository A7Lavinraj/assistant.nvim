local M = {}

M.create_source = function(data, path)
	vim.ui.select({ "cpp", "python" }, { prompt = "Select source language" }, function(choice)
		if choice == "cpp" then
			vim.cmd("e " .. path .. string.gsub(data["name"], " ", "_") .. ".cpp | w")
		elseif choice == "python" then
			vim.cmd("e " .. path .. string.gsub(data["name"], " ", "_") .. ".py | w")
		else
			vim.notify("Selection Abort", 3)
		end
	end)
end

M.create_samples = function(data, path)
	for index, value in ipairs(data["tests"]) do
		local input_file = io.open(path .. string.gsub(data["name"], " ", "_") .. string.format("-%d.in", index), "w")
		local output_file = io.open(path .. string.gsub(data["name"], " ", "_") .. string.format("-%d.exp", index), "w")

		if input_file then
			input_file:write(value["input"])
		else
			print("Something went wrong with input file...")
		end

		if output_file then
			output_file:write(value["output"])
		else
			print("Something went wrong with output file...")
		end
	end
end

M.receive = function()
	local data = {}
	local path = vim.loop.cwd() .. "/" .. vim.fn.expand("%:h") .. "/"
	local server = vim.loop.new_tcp()
	local client = vim.loop.new_tcp()
	local timer = vim.loop.new_timer()
	local function stop_receiving()
		vim.notify("Stoping server...", 3)
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
	server:listen(128, function(err)
		assert(not err, err)
		server:accept(client)
		client:read_start(function(error, chunk)
			assert(not error, error)
			if chunk then
				table.insert(data, chunk)
			else
				data = string.match(table.concat(data), "^.+\r\n(.+)$")
				data = vim.json.decode(data)
				M.create_samples(data, path)
				stop_receiving()
				vim.schedule(function()
					vim.notify("received successfully!", 3)
					M.create_source(data, path)
				end)
			end
		end)
	end)

	-- if after 100 seconds nothing happened stop listening
	timer = vim.loop.new_timer()
	timer:start(100000, 0, stop_receiving)

	if vim.notify then
		vim.notify("Assistant is ready", 3)
	end
end

M.setup = function()
	print("Setup completed")
	vim.api.nvim_create_user_command("Assistant", M.receive, { nargs = 0 })
end

return M
