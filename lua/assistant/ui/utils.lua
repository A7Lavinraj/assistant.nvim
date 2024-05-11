local M = {}

function M.size(max, percent)
  return math.min(max, math.floor(max * percent))
end

function M.fetch(path)
  local file = io.open(path, "r")

  if file then
    return vim.json.decode(file:read())
  end

  return nil
end

return M
