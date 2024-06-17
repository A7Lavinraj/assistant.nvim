local M = {}

function M.emit(pattern)
  vim.cmd("doautocmd User " .. pattern)
end

return M
