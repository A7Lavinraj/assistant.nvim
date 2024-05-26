local M = {}

M.colors = {
  AssistantButton = { link = "CursorLine" },
  AssistantButtonActive = { link = "IncSearch" },
  AssistantH1 = { link = "Bold" },
  AssistantH2 = { link = "Boolean" },
  AssistantText = { link = "AerialNormal" },
  AssistantFadeText = { link = "NonText" },
  AssistantError = { link = "@comment.error" },
  AssistantReady = { link = "@comment.info" },
  AssistantPassed = { link = "@comment.hint" },
  AssistantFailed = { link = "AssistantError" },
  AssistantRunning = { link = "@comment.warning" },
  AssistantKilled = { link = "AssistantError" },
}

function M.load()
  for group, value in pairs(M.colors) do
    vim.api.nvim_set_hl(0, group, { link = value.link, default = true })
  end
end

return M
