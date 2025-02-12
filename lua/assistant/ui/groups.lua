local M = {}

M.groups = {
  AssistantBackdrop = {
    link = "NormalFloat",
  },
  AssistantFloat = {
    link = "NormalFloat",
  },
  AssistantFloatBorder = {
    link = "NonText",
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
    fg = "#bef264",
  },
  AssistantRed = {
    fg = "#fca5a5",
  },
  AssistantYellow = {
    fg = "#fcd34d",
  },
  AssistantDimText = {
    link = "Comment",
  },
}

function M.setup()
  for group, value in pairs(M.groups) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

function M.init()
  if M.did_setup then
    return
  end

  M.did_setup = true
  M.setup()
  vim.api.nvim_create_autocmd("VimEnter", { callback = M.setup })
  vim.api.nvim_create_autocmd("ColorScheme", { callback = M.setup })
end

return M
