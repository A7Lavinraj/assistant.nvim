return function(pattern)
  vim.cmd("doautocmd User " .. pattern)
end
