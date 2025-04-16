if vim.g.loaded_assistant == 1 then
  return
end
vim.g.loaded_assistant = 1

local highlights = {
  AssistantNormal = { default = true, link = 'Normal' },
  AssistantBorder = { default = true, link = 'Conceal' },
  AssistantTitle = { default = true, link = 'Directory' },
  AssistantSuccess = { default = true, link = 'String' },
  AssistantFailure = { default = true, link = 'Error' },
  AssistantWarning = { default = true, link = 'Constant' },
  AssistantHeading = { default = true, link = 'Statement' },
  AssistantParagraph = { default = true, link = 'NavicText' },
}

for k, v in pairs(highlights) do
  vim.api.nvim_set_hl(0, k, v)
end

vim.api.nvim_create_user_command('Assistant', function()
  require('assistant.actions.interface').show_wizard()
end, { nargs = 0 })

vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    for _, interface in ipairs { 'dialog', 'editor', 'picker', 'wizard' } do
      require('assistant.interfaces.' .. interface):resize()
    end
  end,
})
