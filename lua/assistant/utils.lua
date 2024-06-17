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

return M
