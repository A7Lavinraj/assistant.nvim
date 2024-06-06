---@class Text
local Text = {}

function Text.new()
  local self = setmetatable({}, { __index = Text })
  self.lines = {}

  return self
end

function Text:newline()
  table.insert(self.lines, {
    content = "",
    hl = {
      {
        group = "AssistantText",
        col_start = 0,
        col_end = -1,
      },
    },
  })
  return self
end

function Text:append(text)
  table.insert(self.lines, text)

  return self
end

function Text:update(lines)
  self.lines = lines or {}

  return self
end

return Text
