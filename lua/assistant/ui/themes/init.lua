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
}

function M.load()
  for group, value in pairs(dynamic) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

return M
