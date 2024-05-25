local utils = require("assistant.ui.utils")

local AssistantState = {}

function AssistantState.new()
  local self = setmetatable({}, { __index = AssistantState })

  self.CWD = nil
  self.tab = 0
  self.FILETYPE = nil
  self.FILENAME_WITHOUT_EXTENSION = nil
  self.FILENAME_WITH_EXTENSION = nil

  return self
end

function AssistantState:init()
  self.CWD = vim.fn.expand("%:p:h")
  self.FILETYPE = vim.bo.filetype
  self.FILENAME_WITHOUT_EXTENSION = vim.fn.expand("%:t:r")
  self.FILENAME_WITH_EXTENSION = vim.fn.expand("%:t")

  if self.FILENAME_WITHOUT_EXTENSION ~= "" then
    self.test_data = utils.fetch(string.format("%s/.ast/%s", self.CWD, self.FILENAME_WITHOUT_EXTENSION))
  end
end

return AssistantState
