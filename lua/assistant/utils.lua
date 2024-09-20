local M = {}

---@param ratio number | nil
---@return number | nil
function M.width(ratio)
  if not ratio then
    return nil
  end

  return math.min(vim.o.columns, math.floor(vim.o.columns * ratio))
end

---@param ratio number | nil
---@return number | nil
function M.height(ratio)
  if not ratio then
    return nil
  end

  return math.min(vim.o.lines, math.floor(vim.o.lines * ratio))
end

---@param ratio number
---@param align "center" | "start" | "end"
---@return number | nil
function M.row(ratio, align)
  if align == "start" then
    return math.floor(vim.o.lines / 2 - M.height(ratio))
  elseif align == "end" then
    return math.floor(vim.o.lines / 2)
  else
    return math.floor(vim.o.lines / 2 - M.height(ratio) / 2)
  end
end

---@param ratio number
---@param align "center" | "start" | "end"
---@return number | nil
function M.col(ratio, align)
  if align == "start" then
    return math.floor(vim.o.columns / 2 - M.width(ratio))
  elseif align == "end" then
    return math.floor(vim.o.columns / 2)
  else
    return math.floor(vim.o.columns / 2 - M.width(ratio) / 2)
  end
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

---@param text AssistantText
---@param str string
---@param hl string
---@param win number | nil
---@return AssistantText | nil
function M.text_center(text, str, hl, win)
  if win and vim.api.nvim_win_is_valid(win) then
    local config = vim.api.nvim_win_get_config(win)
    text:nl(math.floor(config.height / 2))
    text:append(string.rep(" ", math.ceil(config.width / 2) - math.ceil(#str / 2) - 4), "AssistantText")
    text:append(str, hl)
    return text
  end

  return nil
end

return M
