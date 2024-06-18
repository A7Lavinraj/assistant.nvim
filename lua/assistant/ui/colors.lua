local M = {}

M.colors = {
  AssistantButton = { link = "CursorLine" },
  AssistantButtonActive = { link = "IncSearch" },
  AssistantH1 = { bold = true },
  AssistantText = { link = "@text" },
  AssistantFadeText = { link = "Comment" },
  AssistantError = { link = "@diff.minus" },
  AssistantNote = { link = "@define" },
  AssistantReady = { link = "@define" },
  AssistantPassed = { link = "@diff.plus" },
  AssistantFailed = { link = "AssistantError" },
  AssistantRunning = { link = "@diff.delta" },
  AssistantCompiling = { link = "AssistantRunning" },
  AssistantKilled = { link = "AssistantError" },
}

function M.load()
  for group, value in pairs(M.colors) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

return M
