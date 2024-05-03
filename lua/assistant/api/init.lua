---@class AssistantAPI
local AssistantAPI = {}

function AssistantAPI:sync()
	self.CWD = vim.fn.expand("%:p:h")
	self.FILETYPE = vim.bo.filetype
	self.ABSOLUTE_FILENAME_WITHOUT_EXTENSION = vim.fn.expand("%:p:r")
	self.ABSOLUTE_FILENAME_WITH_EXTENSION = vim.fn.expand("%:p")
	self.RELATIVE_FILENAME_WITHOUT_EXTENSION = vim.fn.expand("%:t:r")
	self.RELATIVE_FILENAME_WITH_EXTENSION = vim.fn.expand("%:t")
end

---@return table | nil
function AssistantAPI:get()
	local sample_file = io.open(string.format("%s/.ast/%s", self.CWD, self.RELATIVE_FILENAME_WITHOUT_EXTENSION), "r")

	if sample_file then
		return vim.json.decode(sample_file:read())
	end

	return nil
end

return AssistantAPI
