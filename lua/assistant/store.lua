local fs = require("assistant.core.filesystem")

---@class AssistantStore
local M = {
  CWD = nil,
  FILETYPE = nil,
  FILENAME_WITHOUT_EXTENSION = nil,
  FILENAME_WITH_EXTENSION = nil,
  COMPILE_STATUS = { code = nil, error = nil },
  CHECKPOINTS = {},
  is_server_running = false,
  fs = fs.new(),
}

function M.fetch()
  M.CWD = vim.fn.expand("%:p:h")
  M.FILETYPE = vim.bo.filetype
  M.FILENAME_WITHOUT_EXTENSION = vim.fn.expand("%:t:r")
  M.FILENAME_WITH_EXTENSION = vim.fn.expand("%:t")
  M.COMPILE_STATUS = { code = nil, error = nil }

  if M.FILENAME_WITHOUT_EXTENSION and M.CWD then
    M.PROBLEM_DATA = fs.fetch(string.format("%s/.ast/%s.json", M.CWD, M.FILENAME_WITHOUT_EXTENSION))
  end
end

function M.write()
  if M.FILENAME_WITHOUT_EXTENSION and M.CWD then
    fs:write(string.format("%s/.ast/%s.json", M.CWD, M.FILENAME_WITHOUT_EXTENSION), vim.json.encode(M.PROBLEM_DATA))
  end
end

return M
