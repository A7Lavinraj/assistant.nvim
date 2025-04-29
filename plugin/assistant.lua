if vim.g.loaded_assistant == 1 then
  return
end
vim.g.loaded_assistant = 1

local state = require 'assistant.state'

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

vim.api.nvim_create_user_command('Assistant', require('assistant.builtins.wizard').standard, { nargs = 0 })

vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    for _, interface in pairs {
      dialog = state.get_local_key 'assistant_dialog',
      editor = state.get_local_key 'assistant_editor',
      picker = state.get_local_key 'assistant_picker',
      previewer = state.get_local_key 'assistant_previewer',
      wizard = state.get_local_key 'assistant_wizard',
    } do
      if interface.window.winid and vim.api.nvim_win_is_valid(interface.window.winid) then
        vim.api.nvim_win_set_config(interface.window.winid, interface.window:get_win_config())
        interface.window:set_local_options()
      end
    end
  end,
})
