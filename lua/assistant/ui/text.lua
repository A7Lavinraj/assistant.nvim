---@class AssistantText
local AssistantText = {}

function AssistantText.new()
  return setmetatable({ padding = 2, lines = { {} } }, { __index = AssistantText })
end

function AssistantText:nl(count)
  for _ = 1, (count or 1) do
    table.insert(self.lines, {})
  end

  return self
end

function AssistantText:append(str, hl)
  table.insert(self.lines[#self.lines], { str = str, hl = hl })

  return self
end

return AssistantText
