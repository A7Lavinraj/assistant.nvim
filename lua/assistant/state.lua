local AssistantState = {}

function AssistantState.new()
  local self = setmetatable({}, { __index = AssistantState })

  self.CWD = nil
  self.FILETYPE = nil
  self.FILENAME_WITHOUT_EXTENSION = nil
  self.FILENAME_WITH_EXTENSION = nil

  return self
end

function AssistantState:sync()
  self.CWD = vim.fn.expand("%:p:h")
  self.FILETYPE = vim.bo.filetype
  self.FILENAME_WITHOUT_EXTENSION = vim.fn.expand("%:t:r")
  self.FILENAME_WITH_EXTENSION = vim.fn.expand("%:t")
end

return AssistantState
