local ButtonSet = {}

function ButtonSet.new()
  local self = setmetatable({}, { __index = ButtonSet })

  self.gap = 2
  self.buttons = {}

  return self
end

function ButtonSet:init(buttons)
  self.buttons = buttons or {}

  return self
end

function ButtonSet:click(index)
  if index == nil or index > #self.buttons or index <= 0 then
    return
  end

  for i = 1, #self.buttons do
    self.buttons[i].is_active = false
    self.buttons[i].group = "AssistantButton"
  end

  self.buttons[index].is_active = true
  self.buttons[index].group = "AssistantButtonActive"
end

return ButtonSet
