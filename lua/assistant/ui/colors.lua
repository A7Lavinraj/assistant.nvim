local M = {}

M.colors = {
  AssistantButton = { link = "CursorLine" },
  AssistantButtonActive = { link = "IncSearch" },
  AssistantH1 = { link = "Bold" },
  AssistantH2 = { link = "Boolean" },
  AssistantText = { link = "AerialNormal" },
  AssistantNonText = { link = "NonText" },
  AssistantDesc = { link = "@comment" },
  AssistantError = { link = "@comment.error" },
  AssistantPassed = { link = "@comment.hint" },
  AssistantFailed = { link = "@comment.error" },
  AssistantRunning = { link = "@comment.info" },
  AssistantKilled = { link = "@comment.warning" },
}

function M.load()
  for group, value in pairs(M.colors) do
    vim.api.nvim_set_hl(0, group, { link = value.link, default = true })
  end
end

return M
