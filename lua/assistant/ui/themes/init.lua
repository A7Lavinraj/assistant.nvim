local M = {}

local dynamic = {
  AssistantFloat = {
    link = "Float",
  },
  AssistantFloatBorder = {
    link = "Conceal",
  },
  AssistantFloatTitle = {
    link = "IncSearch",
  },
  AssistantH1 = {
    fg = "#ffffff",
    bold = true,
  },
  AssistantText = {
    link = "NavicText",
  },
  AssistantGreen = {
    link = "String",
  },
  AssistantRed = {
    link = "Error",
  },
}

function M.init()
  for group, value in pairs(dynamic) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

return M
