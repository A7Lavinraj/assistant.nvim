local Window = require 'assistant.lib.window'
local editor_options = {}
editor_options.width = 0.85
editor_options.height = 0.65
editor_options.root = Window.new {
  name = 'editor',
  enter = true,
  width = 1,
  height = 1,
  width_delta = 2,
  col = (1 - editor_options.width) * 0.5,
  row = (1 - editor_options.height) * 0.5,
  title = ' editor ',
  title_pos = 'center',
  bo = {
    filetype = 'assistant_editor',
  },
  wo = {
    winhighlight = table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ','),
  },
  keys = require('assistant.mappings').default_mappings.editor,
}

---@param self Assistant.Interface
function editor_options.on_show(self)
  local config = require 'assistant.config'
  self:each(function(root)
    vim.api.nvim_create_autocmd('WinClosed', {
      group = config.augroup,
      pattern = tostring(root.winid),
      callback = function()
        self:hide()
      end,
    })
  end)
end

return setmetatable({}, { __index = require('assistant.lib.interface').new(editor_options) })
