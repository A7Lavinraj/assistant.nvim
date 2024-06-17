---@class AssistantWindowState
local AssistantWindowState = {}

---@return AssistantWindowState
function AssistantWindowState.new()
  return setmetatable({ is_open = false }, { __index = AssistantWindowState })
end

return AssistantWindowState
