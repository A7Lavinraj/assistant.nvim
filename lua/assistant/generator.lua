local utils = require("assistant.utils")

return {
	--- @param data string: The data received from the client
	--- @param path string: The path where files will be created
	store_problem = function(data, path)
		local filename = utils.get_filtered_filename(vim.json.decode(data)["name"])
		local file = io.open(vim.fs.joinpath(path, filename) .. ".prob", "w")

		if file then
			file:write(tostring(data))
		end
	end,

	--- @param data string: The data received from the client
	--- @param path string: The path where files will be created
	generate_source = function(data, path)
		local parsed_data = vim.json.decode(data)
		local filename = utils.get_filtered_filename(parsed_data["name"])
		local full_path = vim.fs.joinpath(path, filename)

		if filename == nil then
			return
		end

		vim.ui.select(utils.get_sources(), { prompt = "Select source language" }, function(choice)
			if choice == "c" then
				vim.cmd("e " .. full_path .. ".c | w")
			elseif choice == "cpp" then
				vim.cmd("e " .. full_path .. ".cpp | w")
			elseif choice == "python" then
				vim.cmd("e " .. full_path .. ".py | w")
			elseif choice == "rust" then
				vim.cmd("e " .. full_path .. ".rs | w")
			else
				vim.notify("Selection Aborted", 3) -- nothing get selected
			end
		end)
	end,
}
