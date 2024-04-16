return {
	---@return table
	get_sources = function()
		local sources = {}
		local options = {
			c = "gcc",
			cpp = "g++",
			python = "python",
			python3 = "python3",
			rust = "rustc",
		}

		for key, value in pairs(options) do
			local source = io.popen(value .. " --version")

			if source then
				table.insert(sources, key)
			end
		end

		return sources
	end,

	---@param filename string
	---@param callback function
	get_compiled = function(filename, callback)
		local filetype = vim.bo.filetype

		if filetype == "c" then
			vim.fn.jobstart({ "gcc", filename .. ".c" }, { on_exit = callback })
		elseif filetype == "cpp" then
			vim.fn.jobstart({ "g++", filename .. ".cpp" }, { on_exit = callback })
		elseif filetype == "rust" then
			vim.fn.jobstart({ "rustc", filename .. ".rs" }, { on_exit = callback })
		elseif filetype == "python" then
			callback()
		end
	end,

	---@param str string
	---@return string
	get_filtered_string = function(str)
		str = string.gsub(str, "\n", " ")
		str = string.gsub(str, "%s+", " ")
		str = string.gsub(str, "^%s", "")
		str = string.gsub(str, "%s$", "")

		return str
	end,

	---@param filename string
	---@return string | nil
	get_filtered_filename = function(filename)
		if filename == nil then
			return nil
		end

		local result = ""
		local function is_valid(char)
			return ("0" <= char and char <= "9")
				or ("A" <= char and char <= "Z")
				or ("a" <= char and char <= "z")
				or char == "."
		end

		for i = 1, #filename do
			if is_valid(string.sub(filename, i, i)) then
				result = result .. string.sub(filename, i, i)
			end
		end

		return result
	end,

	get_split = function(str)
		local substrings = {}

		for substring in str:gmatch("[^" .. "\n" .. "]+") do
			table.insert(substrings, substring)
		end

		return substrings
	end,
}
