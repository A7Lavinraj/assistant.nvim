local utils = require("assistant.utils")

local M = {}

M.CWD = nil
M.TAB = 1
M.FILETYPE = nil
M.FILENAME_WITHOUT_EXTENSION = nil
M.FILENAME_WITH_EXTENSION = nil
M.COMPILE_STATUS = { code = nil, error = nil }

function M.init()
  M.TAB = 1
  M.CWD = vim.fn.expand("%:p:h")
  M.FILETYPE = vim.bo.filetype
  M.FILENAME_WITHOUT_EXTENSION = vim.fn.expand("%:t:r")
  M.FILENAME_WITH_EXTENSION = vim.fn.expand("%:t")
  M.COMPILE_STATUS = { code = nil, error = nil }

  print(vim.inspect(vim.bo.filetype))

  if M.FILENAME_WITHOUT_EXTENSION and M.CWD then
    M.PROBLEM_DATA = utils.fetch(string.format("%s/.ast/%s.json", M.CWD, M.FILENAME_WITHOUT_EXTENSION))
  end
end

return M
