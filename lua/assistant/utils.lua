local M = {}

---@param msg string
function M.notify_info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "Assistant.nvim" })
end

---@param msg string
function M.notify_warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "Assistant.nvim" })
end

---@param msg string
function M.notify_err(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "Assistant.nvim" })
end

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

---@param str string
---@param n number
---@return table<string>
function M.slice_first_n_lines(str, n)
  local lines = {}

  for line in str:gmatch("[^\n]*") do
    if line ~= "" then
      table.insert(lines, line)
    end

    if #lines == n then
      break
    end
  end

  return lines
end

---@param buf number
---@param text AssistantText
function M.render(buf, text)
  local lines = {}
  local access = vim.api.nvim_get_option_value("modifiable", { buf = buf })

  for _, row in pairs(text.lines) do
    local line = string.rep(" ", text.padding)

    for i, col in pairs(row) do
      line = line .. col.str .. string.rep(" ", i == #row and 0 or 1)
    end

    table.insert(lines, line)
  end

  if buf and vim.api.nvim_buf_is_valid(buf) then
    if not access then
      vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  for cnt, row in pairs(text.lines) do
    local offset = text.padding

    for _, col in pairs(row) do
      if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_add_highlight(buf, 0, col.hl, cnt - 1, offset, offset + #col.str)
      end

      offset = offset + #col.str + 1
    end
  end

  if buf and vim.api.nvim_buf_is_valid(buf) then
    if not access then
      vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    end
  end
end

---@return number?
function M.get_current_line_number()
  return tonumber(vim.api.nvim_get_current_line():match("testcase #(%d+)%s+"))
end

return M
