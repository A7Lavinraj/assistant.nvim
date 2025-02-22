local fs = require("assistant.core.filesystem").new()
local luv = vim.uv or vim.loop
local M = {}
M._data_map = {}

---@return string?
function M.get_problem_name()
  return M._data_map["name"]
end

---@return string
function M.get_src_ft()
  return M._data_map["src_ft"]
end

---@return string, string
function M.get_src_name()
  return M._data_map["src_name"], M._data_map["src_ext"]
end

---@return  string
function M.get_cwd()
  return M._data_map["cwd"]
end

---@return table?
function M.get_all_tests()
  return M._data_map["tests"]
end

---@param id number
function M.get_test_by_id(id)
  return M._data_map["tests"][id]
end

---@return boolean
function M.need_compilation()
  if M._data_map["need_compilation"] == nil then
    M.set_by_key("need_compilation", function()
      return true
    end)
  end

  return M._data_map["need_compilation"]
end

---@param key string
---@param callback fun(any): any
function M.set_by_key(key, callback)
  if type(M._data_map[key]) == "table" then
    M._data_map[key] = callback(vim.deepcopy(M._data_map[key]))
  else
    M._data_map[key] = callback(M._data_map[key])
  end
end

function M.update()
  M.set_by_key("src_name", function()
    return vim.fn.expand("%:t:r")
  end)

  M.set_by_key("src_ext", function()
    return vim.fn.expand("%:e")
  end)

  M.set_by_key("src_ft", function()
    return vim.bo.filetype
  end)

  local name, _ = M.get_src_name()
  local filepath = string.format("%s/.ast/%s.json", luv.cwd(), name)
  local problem_data = fs.fetch(filepath)

  M.set_by_key("tests", function()
    if problem_data == nil then
      return {}
    end

    return problem_data["tests"]
  end)

  M.set_by_key("name", function()
    if problem_data == nil then
      return nil
    end

    return problem_data["name"]
  end)
end

function M.write_all()
  local name, _ = M.get_src_name()

  if not name then
    return
  end

  local filepath = string.format("%s/.ast/%s.json", luv.cwd(), name)
  fs:write(filepath, vim.json.encode(vim.tbl_deep_extend("force", fs.fetch(filepath) or {}, M._data_map or {})))
end

return M
