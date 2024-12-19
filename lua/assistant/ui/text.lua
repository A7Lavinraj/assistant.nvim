---@class AssistantText
local AssistantText = {}

---@return AssistantText
function AssistantText.new()
  local self = setmetatable({}, { __index = AssistantText })
  self.padding = 2
  self.lines = { {} }
  return self
end

---@param count integer?
function AssistantText:nl(count)
  for _ = 1, (count or 1) do
    table.insert(self.lines, {})
  end

  return self
end

---@param str string
---@param hl string
function AssistantText:append(str, hl)
  table.insert(self.lines[#self.lines], { str = str, hl = hl })

  return self
end

return AssistantText
