local utils = require("assistant.utils")

---@param output string
---@param expected string
---@return boolean
local comparator = function(output, expected)
	output = utils.get_filtered_string(output)
	expected = utils.get_filtered_string(expected)

	return output == expected
end

return comparator
