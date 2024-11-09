local config = require("assistant.config")
local FileSystem = {}

function FileSystem.new()
  return setmetatable({}, { __index = FileSystem })
end

function FileSystem:__init__()
  if vim.fn.isdirectory(".ast") == 0 then
    vim.fn.mkdir(".ast")
  end
end

---@param filename string
function FileSystem:create(filename)
  local sources = {}

  for key, _ in pairs(config.commands) do
    table.insert(sources, key)
  end

  vim.ui.select(sources, { prompt = "Select source" }, function(source)
    if source then
      local extension = config.commands[source].extension
      vim.cmd(string.format("edit %s.%s | w", filename, extension))
    end
  end)
end

---@param path string
---@param mode string
---@return string?
function FileSystem:read(path, mode)
  local fd, _ = vim.uv.fs_open(path, mode, 438)

  if not fd then
    return
  end

  local stat = vim.uv.fs_fstat(fd)
  local file_size = stat and stat.size or 0
  local data = vim.uv.fs_read(fd, file_size)
  vim.uv.fs_close(fd)
  return data
end

---@param path string
---@param bytes string
function FileSystem:write(path, bytes)
  local fd, _ = vim.uv.fs_open(path, "w", 438)

  if not fd then
    print("[ERROR]: can't open file", path)
    return
  end

  vim.uv.fs_write(fd, bytes)
  vim.uv.fs_close(fd)
end

---@param chunk string
function FileSystem:save(chunk)
  self:__init__()
  chunk = string.match(chunk, "^.+\r\n(.+)$")
  local data = vim.json.decode(chunk)

  if data.languages.java.taskClass then
    vim.schedule(function()
      self:write(string.format("%s/.ast/%s.json", vim.fn.expand("%:p:h"), data.languages.java.taskClass), chunk)
      self:create(data.languages.java.taskClass)
    end)
  end
end

return FileSystem
