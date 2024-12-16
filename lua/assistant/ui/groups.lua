local config = require("assistant.config")
local M = {}

local dynamic = {
  AssistantFloat = {
    link = "Float",
  },
  AssistantFloatBorder = {
    link = "Conceal",
  },
  AssistantFloatTitle = {
    link = "CursorLineNr",
  },
  AssistantH1 = {
    fg = "#ffffff",
    bold = true,
  },
  AssistantText = {
    link = "NavicText",
  },
  AssistantGreen = {
    fg = "#00ff00",
  },
  AssistantRed = {
    fg = "#ff0000",
  },
  AssistantYellow = {
    fg = "#ffff00",
  },
  AssistantDimText = {
    link = "Comment",
  },
}

function M.init()
  local ns = config.ns or 0

  for group, value in pairs(dynamic) do
    vim.api.nvim_set_hl(ns, group, value)
  end
end

return M
