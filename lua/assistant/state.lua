local state = {}
local HashTable = { local_data = {}, global_data = {} }

function state.set_global_key(key, value)
  HashTable.global_data[key] = value
end

function state.get_global_key(key)
  return HashTable.global_data[key]
end

function state.set_local_key(key, value)
  HashTable.local_data[key] = value
end

function state.get_local_key(key)
  return HashTable.local_data[key]
end

function state.sync_and_clean()
  local fs = require 'assistant.core.fs'

  if vim.tbl_isempty(HashTable.global_data.tests or {}) then
    return
  end

  if not fs.make_root() then
    return
  end

  local filepath = fs.get_state_filepath()

  if not filepath then
    return
  end

  fs.write(filepath, vim.json.encode(HashTable.global_data))

  HashTable = {
    global_data = {},
    local_data = {},
  }
end

return state
