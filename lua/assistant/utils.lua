local M = {}

function M.width(ratio)
  return math.min(vim.o.columns, math.floor(vim.o.columns * ratio))
end

function M.height(ratio)
  return math.min(vim.o.lines, math.floor(vim.o.lines * ratio))
end

function M.row(ratio)
  return math.floor((vim.o.lines - M.height(ratio)) / 2)
end

function M.col(ratio)
  return math.floor((vim.o.columns - M.width(ratio)) / 2)
end

function M.fetch(path)
  local file = io.open(path, "r")

  if file then
    return vim.json.decode(file:read())
  end

  return nil
end

function M.compare(stdout, expected)
  local function process_str(str)
    return (str or ""):gsub("\n", " "):gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")
  end

  return process_str(stdout) == process_str(expected)
end

function M.get_stream_data(received)
  return table.concat(vim.split(string.gsub(received, "\r\n", "\n"), "\n", { plain = true }), "\n")
end

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
