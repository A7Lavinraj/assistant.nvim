---@class AssistantText
local AssistantText = {}
AssistantText.__index = AssistantText

function AssistantText:new()
	return setmetatable({
		content = {},
	}, AssistantText)
end

function AssistantText:newline()
	table.insert(self.content, "")
end

function AssistantText:append(text)
	table.insert(self.content, string.rep(" ", 2) .. text)
end

return AssistantText
