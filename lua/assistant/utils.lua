local M = {}

---@param ratio number
---@return number
function M.width(ratio)
  return math.min(vim.o.columns, math.floor(vim.o.columns * ratio))
end

---@param ratio number
---@return number
function M.height(ratio)
  return math.min(vim.o.lines, math.floor(vim.o.lines * ratio))
end

---@param ratio number
---@return number
function M.row(ratio)
  return math.floor((vim.o.lines - M.height(ratio)) / 2)
end

---@param ratio number
---@return number
function M.col(ratio)
  return math.floor((vim.o.columns - M.width(ratio)) / 2)
end

---@param path string | nil
---@return table | nil
function M.fetch(path)
  if not path then
    return nil
  end

  local fd = vim.loop.fs_open(path, "r", 438)

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

---@param stdout string
---@param expected string
---@return boolean
function M.compare(stdout, expected)
  local function process_str(str)
    return (str or ""):gsub("\n", " "):gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")
  end

  return process_str(stdout) == process_str(expected)
end

---@param received string
---@return string
function M.get_stream_data(received)
  return table.concat(vim.split(string.gsub(received, "\r\n", "\n"), "\n", { plain = true }), "\n")
end

---@param FILENAME_WITH_EXTENSION string | nil
---@param FILENAME_WITHOUT_EXTENSION string | nil
---@param command table | nil
---@return table | nil
function M.interpolate(FILENAME_WITH_EXTENSION, FILENAME_WITHOUT_EXTENSION, command)
  if not command then
    return nil
  end

  local function replace(filename)
    return filename
      :gsub("%$FILENAME_WITH_EXTENSION", FILENAME_WITH_EXTENSION)
      :gsub("%$FILENAME_WITHOUT_EXTENSION", FILENAME_WITHOUT_EXTENSION)
  end

  local modified = vim.deepcopy(command)

  if modified.main then
    modified.main = replace(modified.main)
  end

  if modified.args then
    for i = 1, #command.args do
      modified.args[i] = replace(command.args[i])
    end
  end

  return modified
end

return M
