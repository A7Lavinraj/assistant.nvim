if vim.g.loaded_assistant == 1 then
  return
end
vim.g.loaded_assistant = 1

local state = require 'assistant.state'
local utils = require 'assistant.utils'

local highlights = {
  AssistantNormal = { default = true, link = 'NormalFloat' },
  AssistantBorder = { default = true, link = 'FloatBorder' },
  AssistantTitle = { default = true, link = 'FloatTitle' },
  AssistantSuccess = { default = true, link = 'String' },
  AssistantFailure = { default = true, link = 'Error' },
  AssistantWarning = { default = true, link = 'Constant' },
  AssistantHeading = { default = true, link = 'Statement' },
  AssistantParagraph = { default = true, link = 'NavicText' },
}

for k, v in pairs(highlights) do
  vim.api.nvim_set_hl(0, k, v)
end

vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    for _, window in pairs {
      panel = state.get_local_key 'assistant-panel-window',
      previewer = state.get_local_key 'assistant-previewer-window',
      picker = state.get_local_key 'assistant-picker-window',
      patcher = state.get_local_key 'assistant-patcher-window',
      dialog = state.get_local_key 'assistant-dialog-window',
      terminal = state.get_local_key 'assistant-terminal-window',
    } do
      if window and window.winid and vim.api.nvim_win_is_valid(window.winid) then
        utils.set_win_config(window.winid, utils.get_win_config(window))

        for k, v in pairs(window.bo or {}) do
          utils.set_buf_option(window, k, v)
        end

        for k, v in pairs(window.wo or {}) do
          utils.set_win_option(window, k, v)
        end
      end
    end
  end,
})
