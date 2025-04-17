local state = {}
local AssistantHashTable = {}

function state.set_global_key(key, value)
  AssistantHashTable[key] = value
end

function state.get_global_key(key)
  return AssistantHashTable[key]
end

function state.sync_with_fs()
  local fs = require 'assistant.core.fs'
  local filepath = fs.get_state_filepath()
  if not filepath then
    return
  end
  fs.write(filepath, vim.json.encode(AssistantHashTable))
end

return state
