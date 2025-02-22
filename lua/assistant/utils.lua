local M = {}

local DELIMITER = "==== PLEASE DO NOT EDIT THIS LINE ====="

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

function M.is_buf(buf)
  if not buf then
    return false
  end

  return vim.api.nvim_buf_is_valid(buf)
end

function M.is_win(win)
  if not win then
    return false
  end

  return vim.api.nvim_win_is_valid(win)
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

---@return number?
function M.get_current_line_number()
  return tonumber(vim.api.nvim_get_current_line():match("^%s*.+%s*Testcase #(%d+)"))
end

function M.next_test()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local pos = vim.api.nvim_win_get_cursor(win)

  if lines[pos[1]]:match("^%s*.+%s*Testcase #%d+") then
    pos[1] = pos[1] + 1
  end

  for i = pos[1], #lines do
    if lines[i]:match("^%s*.+%s*Testcase #%d+") then
      pos = { i, 0 }
      vim.api.nvim_win_set_cursor(win, pos)
      return
    end
  end
end

function M.prev_test()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local pos = vim.api.nvim_win_get_cursor(win)

  if lines[pos[1]]:match("^%s*.+%s*Testcase #%d+") then
    pos[1] = pos[1] - 1
  end

  for i = pos[1], 1, -1 do
    if lines[i]:match("^%s*.+%s*Testcase #%d+") then
      pos = { i, 0 }
      vim.api.nvim_win_set_cursor(win, pos)
      return
    end
  end
end

---@param text Ast.Text
---@param input string
---@param output string
function M.io_to_text(text, input, output)
  local split_lines = vim.split(input, "\n")

  for _, line in ipairs(split_lines) do
    text:append(line, "AstTextP"):nl()
  end

  text:append(DELIMITER, "AstTextDim"):nl()

  split_lines = vim.split(output, "\n")

  for index, line in ipairs(split_lines) do
    text:append(line, "AstTextP")

    if index < #split_lines then
      text:nl()
    end
  end
end

---@param lines string
function M.text_to_io(lines)
  return lines:match("^(.-)\n+" .. DELIMITER .. "\n+(.*)$")
end

function M.to_snake_case(str)
  local result = str:gsub("(%s)", "_"):gsub("(%u%l)", "_%1"):gsub("(%l)(%u)", "%1_%2"):gsub("^_", "")

  return result
    :gsub("^%s*(.-)%s*$", "%1")
    :gsub("%s+", "_")
    :gsub("(%l)(%u)", "%1_%2")
    :gsub("(%l)(%d)", "%1_%2")
    :gsub("(%d)(%l)", "%1_%2")
    :gsub("(%d)(%u)", "%1_%2")
end

return M
