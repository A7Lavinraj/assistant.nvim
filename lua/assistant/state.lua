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
  local filename = state.get_global_key 'filename'
  local root_dir = fs.find_or_make_root()
  local filepath = string.format('%s/.ast/%s.json', root_dir, filename)
  fs.write(filepath, vim.json.encode(AssistantHashTable))
end

return state
