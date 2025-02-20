local opts = require("assistant.config").opts
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
    filtered_data["name"] = parsed["name"]
    filtered_data["tests"] = parsed["tests"]
    return filtered_data
  end

  return nil
end

---@param filename string
function FileSystem.create(filename)
  local sources = {}

  for key, _ in pairs(opts.commands) do
    table.insert(sources, key)
  end

  vim.ui.select(sources, { prompt = "select source" }, function(source)
    if source then
      local extension = opts.commands[source].extension
      vim.cmd(string.format("edit %s.%s | w", filename, extension))

      if opts.commands[source].template then
        utils.notify_info("populating with " .. opts.commands[source].template)
        vim.cmd(string.format("0read %s", opts.commands[source].template))
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
  -- Helper function to convert to snake_case
  local function to_snake_case(str)
    -- Convert spaces to underscores and handle camel-case and consecutive capital letters
    local result = str:gsub("(%s)", "_"):gsub("(%u%l)", "_%1"):gsub("(%l)(%u)", "%1_%2"):gsub("^_", "")
    return result
      :gsub("^%s*(.-)%s*$", "%1")
      :gsub("%s+", "_")
      :gsub("(%l)(%u)", "%1_%2")
      :gsub("(%l)(%d)", "%1_%2")
      :gsub("(%d)(%l)", "%1_%2")
      :gsub("(%d)(%u)", "%1_%2")
  end

  self.__init__()
  chunk = string.match(chunk, "^.+\r\n(.+)$")
  local data = vim.json.decode(chunk)

  if data.languages.java.taskClass then
    vim.schedule(function()
      local filtered_data = self.filter(chunk)
      local task_class_snake = to_snake_case(data.languages.java.taskClass) -- Convert to snake_case
      local filepath = string.format("%s/.ast/%s.json", vim.fn.expand("%:p:h"), task_class_snake)

      if filtered_data then
        self:write(filepath, vim.json.encode(filtered_data))
        self.create(task_class_snake)
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
