---@class AssistantText
local Text = {}

function Text.new()
  local self = setmetatable({}, { __index = Text })
  self.padding = 2
  self.lines = { {} }

  return self
end

function Text:nl(count)
  for _ = 1, (count or 1) do
    table.insert(self.lines, {})
  end

  return self
end

function Text:append(str, hl)
  table.insert(self.lines[#self.lines], { str = str, hl = hl })

  return self
end

function Text:update(lines)
  self.lines = lines or { {} }

  return self
end

return Text
