local config = require("assistant.config")
local utils = require("assistant.utils")
local FileSystem = {}
local luv = vim.uv or vim.loop

function FileSystem.new()
  return setmetatable({}, { __index = FileSystem })
end

function FileSystem.__init__()
  if vim.fn.isdirectory(".ast") == 0 then
    vim.fn.mkdir(".ast")
  end
end

---@param chunk string
---@return table?
function FileSystem.filter(chunk)
  local parsed = vim.json.decode(chunk)

  if parsed then
    local filtered_data = {}
    filtered_data["problem_name"] = parsed["name"]
    filtered_data["tests"] = parsed["tests"]
    return filtered_data
  end

  return nil
end

---@param filename string
function FileSystem.create(filename)
  local sources = {}

  for key, _ in pairs(config.options.commands) do
    table.insert(sources, key)
  end

  vim.ui.select(sources, { prompt = "Select source | " }, function(source)
    if source then
      local extension = config.options.commands[source].extension
      vim.cmd(string.format("edit %s.%s | w", filename, extension))

      if config.options.core.template_file then
        utils.notify_info("populating with " .. config.options.core.template_file)
        vim.cmd(string.format("0read %s", config.options.core.template_file))
      end
    end
  end)
end

---@param path string
---@param mode string
---@return string?
function FileSystem.read(path, mode)
  local fd, _ = luv.fs_open(path, mode, 438)

  if not fd then
    return
  end

  local stat = luv.fs_fstat(fd)
  local file_size = stat and stat.size or 0
  local data = luv.fs_read(fd, file_size)
  luv.fs_close(fd)
  return data
end

---@param path string
---@param bytes string
function FileSystem:write(path, bytes)
  self.__init__()
  local fd, _ = luv.fs_open(path, "w", 438)

  if not fd then
    print("[ERROR]: can't open file", path)
    return
  end

  luv.fs_write(fd, bytes)
  luv.fs_close(fd)
end

---@param chunk string
function FileSystem:save(chunk)
  self.__init__()
  chunk = string.match(chunk, "^.+\r\n(.+)$")
  local data = vim.json.decode(chunk)

  if data.languages.java.taskClass then
    vim.schedule(function()
      local filtered_data = self.filter(chunk)
      local filepath = string.format("%s/.ast/%s.json", vim.fn.expand("%:p:h"), data.languages.java.taskClass)

      if filtered_data then
        self:write(filepath, vim.json.encode(filtered_data))
        self.create(data.languages.java.taskClass)
      end
    end)
  end
end

---@param path string | nil
---@return table | nil
function FileSystem.fetch(path)
  if not path then
    return nil
  end

  local fd = luv.fs_open(path, "r", 438)

  if not fd then
    return nil
  end

  local stat = vim.loop.fs_fstat(fd)

  if not stat then
    return nil
  end

  local data = vim.loop.fs_read(fd, stat.size, 0)

  if (not data) or (data:gsub("\r\n", "\n") == "") then
    return nil
  end

  vim.loop.fs_close(fd)
  return vim.json.decode(data)
end

return FileSystem
