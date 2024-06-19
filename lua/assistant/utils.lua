local M = {}

function M.size(max, percent)
  return math.min(max, math.floor(max * percent))
end

function M.fetch(path)
  if not path then
    return nil
  end

  local file = io.open(path, "r")

  if file then
    return vim.json.decode(file:read())
  end

  return nil
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

  local _command = vim.deepcopy(command)

  if _command.main then
    _command.main = replace(_command.main)
  end

  if _command.args then
    for i = 1, #command.args do
      _command.args[i] = replace(command.args[i])
    end
  end

  return _command
end

return M
