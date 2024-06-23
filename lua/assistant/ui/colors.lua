local M = {}

M.colors = {
  AssistantButton = { link = "CursorLine" },
  AssistantButtonActive = { link = "IncSearch" },
  AssistantH1 = { bold = true },
  AssistantText = { link = "@text" },
  AssistantFadeText = { link = "Comment" },
  AssistantError = { link = "@comment.error" },
  AssistantNote = { link = "@define" },
  AssistantReady = { link = "@comment.todo" },
  AssistantPassed = { link = "@comment.note" },
  AssistantFailed = { link = "AssistantError" },
  AssistantRunning = { link = "@comment.warning" },
  AssistantCompiling = { link = "AssistantRunning" },
  AssistantKilled = { link = "AssistantError" },
}

function M.load()
  for group, value in pairs(M.colors) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

return M
