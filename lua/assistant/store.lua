local utils = require("assistant.utils")

local AssistantStore = {}

function AssistantStore.new()
  return setmetatable({
    CWD = nil,
    TAB = 1,
    FILETYPE = nil,
    FILENAME_WITHOUT_EXTENSION = nil,
    FILENAME_WITH_EXTENSION = nil,
    COMPILE_STATUS = { code = nil, error = nil },
  }, { __index = AssistantStore })
end

function AssistantStore:init()
  self.TAB = 1
  self.CWD = vim.fn.expand("%:p:h")
  self.FILETYPE = vim.bo.filetype
  self.FILENAME_WITHOUT_EXTENSION = vim.fn.expand("%:t:r")
  self.FILENAME_WITH_EXTENSION = vim.fn.expand("%:t")
  self.COMPILE_STATUS = { code = nil, error = nil }

  if self.FILENAME_WITHOUT_EXTENSION and self.CWD then
    self.PROBLEM_DATA = utils.fetch(
      string.format(
        "%s/.ast/%s.json",
        self.CWD,
        self.FILENAME_WITHOUT_EXTENSION
      )
    )
  end
end

return AssistantStore.new()
