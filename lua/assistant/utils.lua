local M = {}

---@param filename string | nil
---@return string | nil
M.filter_filename = function(filename)
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
end

return M
