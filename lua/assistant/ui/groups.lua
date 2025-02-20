local M = {}

M.groups = {
  BackdropNormalFloat = {
    bg = "#000000",
  },
  TasksNormalFloat = {
    link = "NormalFloat",
  },
  TasksFloatBorder = {
    link = "Conceal",
  },
  TasksFloatTitle = {
    link = "FloatTitle",
  },
  ActionsNormalFloat = {
    link = "NormalFloat",
  },
  ActionsFloatBorder = {
    link = "Conceal",
  },
  ActionsFloatTitle = {
    link = "FloatTitle",
  },
  LogsNormalFloat = {
    link = "NormalFloat",
  },
  LogsFloatBorder = {
    link = "Conceal",
  },
  LogsFloatTitle = {
    link = "FloatTitle",
  },
  TextH1 = {
    fg = "#ffffff",
    bold = true,
  },
  TextP = {
    link = "NavicText",
  },
  TextGreen = {
    fg = "#bef264",
  },
  TextRed = {
    fg = "#fca5a5",
  },
  TextYellow = {
    fg = "#fcd34d",
  },
  TextDim = {
    fg = "#5C6370",
  },
}

function M.setup()
  for group, value in pairs(M.groups) do
    vim.api.nvim_set_hl(0, "Ast" .. group, value)
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
