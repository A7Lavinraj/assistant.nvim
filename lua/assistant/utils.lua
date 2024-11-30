local M = {}

---@param received string
---@return string
function M.get_stream_data(received)
  return table.concat(vim.split(string.gsub(received, "\r\n", "\n"), "\n", { plain = true }), "\n")
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

---@param pattern string
function M.emit(pattern)
  vim.cmd("doautocmd User " .. pattern)
end

---@return number, number
function M.get_view_port()
  local vh = vim.o.lines - vim.o.cmdheight
  local vw = vim.o.columns

  if vim.o.laststatus ~= 0 then
    vh = vh - 1
  end

  return vh, vw
end

return M
