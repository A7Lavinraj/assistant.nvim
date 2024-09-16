local utils = require("assistant.utils")

---@class AssistantWindowState
local AssistantWindowState = {}

---@return AssistantWindowState
function AssistantWindowState.new(config)
  return setmetatable({
    is_open = false,
    width_ratio = config.width,
    height_ratio = config.height,
    row = config.row,
    col = config.col,
    config = config,
    data = {},
  }, { __index = AssistantWindowState })
end

---@return table
function AssistantWindowState:get_config()
  if not self.config then
    print("Window config not found!")
    return {}
  end

  return vim.tbl_deep_extend("force", self.config, {
    height = utils.height(self.height_ratio),
    width = utils.width(self.width_ratio),
    row = utils.row(self.height_ratio, self.row),
    col = utils.col(self.width_ratio, self.col),
  })
end

return AssistantWindowState
