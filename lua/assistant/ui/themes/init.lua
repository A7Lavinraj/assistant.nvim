local config = require("assistant.config")
local palette = require("assistant.ui.themes.palettes")
local M = {}

local function get_custom_theme(theme)
  local colors = palette[theme]

  if not colors then
    return nil
  end

  return {
    AssistantFloatBorder = { bg = colors.PRIMARY, fg = colors.SECONDARY },
    AssistantNormalFloat = { bg = colors.PRIMARY },
    AssistantButton = { bg = colors.SECONDARY, fg = colors.WHITE },
    AssistantButtonActive = { bg = colors.ACCENT, fg = colors.BLACK },
    AssistantH1 = { bold = true, fg = colors.WHITE },
    AssistantText = { fg = colors.WHITE },
    AssistantFadeText = { fg = colors.DIMMED },
    AssistantError = { fg = colors.RED },
    AssistantNote = { fg = colors.WHITE },
    AssistantReady = { fg = colors.WHITE },
    AssistantPassed = { fg = colors.GREEN },
    AssistantRunning = { fg = colors.YELLOW },
    AssistantFailed = { link = "AssistantError" },
    AssistantKilled = { link = "AssistantError" },
    AssistantCompiling = { link = "AssistantRunning" },
  }
end

local dynamic = {
  AssistantFloatBorder = { link = "FloatBorder" },
  AssistantNormalFloat = { link = "NormalFloat" },
  AssistantButton = { link = "CursorLine" },
  AssistantButtonActive = { link = "IncSearch" },
  AssistantH1 = { bold = true },
  AssistantText = { link = "@text" },
  AssistantFadeText = { link = "NonText" },
  AssistantError = { link = "DiagnosticError" },
  AssistantNote = { link = "White" },
  AssistantReady = { link = "DiagnosticInfo" },
  AssistantPassed = { link = "DiagnosticOk" },
  AssistantFailed = { link = "AssistantError" },
  AssistantRunning = { link = "DiagnosticWarn" },
  AssistantCompiling = { link = "AssistantRunning" },
  AssistantKilled = { link = "AssistantError" },
}

function M.load()
  for group, value in pairs(get_custom_theme(config.theme) or dynamic) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

return M
