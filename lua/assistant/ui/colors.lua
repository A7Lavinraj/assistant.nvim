local M = {}

M.colors = {
  AssistantNormal = { link = "NormalFloat" },
  AssistantButton = { link = "CursorLine" },
  AssistantButtonActive = { link = "IncSearch" },
  AssistantH1 = { bold = true },
  AssistantText = { link = "@text" },
  AssistantFadeText = { link = "Comment" },
  AssistantError = { link = "DiagnosticError" },
  AssistantNote = { link = "@define" },
  AssistantReady = { link = "DiagnosticInfo" },
  AssistantPassed = { link = "DiagnosticOk" },
  AssistantFailed = { link = "AssistantError" },
  AssistantRunning = { link = "DiagnosticWarn" },
  AssistantCompiling = { link = "AssistantRunning" },
  AssistantKilled = { link = "AssistantError" },
}

function M.load()
  for group, value in pairs(M.colors) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

return M
