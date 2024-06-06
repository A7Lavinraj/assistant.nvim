local M = {}

local white = "White"
local black = "Black"
local orange = "#fab387"
local gray = "#6c7086"
local red = "#f38ba8"
local blue = "#b4befe"
local green = "#a6e3a1"
local yellow = "#f9e2af"

M.colors = {
  AssistantButton = { bg = gray, fg = black },
  AssistantButtonActive = { bg = orange, fg = black },
  AssistantH1 = { bold = true, fg = white },
  AssistantH2 = { fg = orange },
  AssistantText = {},
  AssistantFadeText = { fg = gray },
  AssistantError = { fg = red },
  AssistantNote = { bg = gray, fg = black },
  AssistantReady = { fg = blue },
  AssistantPassed = { fg = green },
  AssistantFailed = { link = "AssistantError" },
  AssistantRunning = { fg = yellow },
  AssistantKilled = { link = "AssistantError" },
}

function M.load()
  for group, value in pairs(M.colors) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

return M
