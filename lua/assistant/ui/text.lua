local Text = {}

function Text.new()
  local self = setmetatable({}, { __index = Text })
  self.lines = {}

  return self
end

function Text:newline()
  table.insert(self.lines, { content = "", group = "AssistantNonText" })
  return self
end

function Text:append(content, group)
  table.insert(self.lines, { content = content, group = group })
  return self
end

function Text:update(lines)
  self.lines = lines or {}

  return self
end

return Text
