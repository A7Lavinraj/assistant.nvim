local Window = require 'assistant.lib.window'
local dialog_options = {}
dialog_options.width = 0.85
dialog_options.height = 0.65
dialog_options.root = Window.new {
  name = 'dialog',
  enter = true,
  width = 1,
  height = 1,
  width_delta = 2,
  col = (1 - dialog_options.width) * 0.5,
  row = (1 - dialog_options.height) * 0.5,
  title = ' Dialog ',
  title_pos = 'center',
  bo = {
    modifiable = false,
    filetype = 'assistant_dialog',
  },
  wo = {
    winhighlight = table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ','),
  },
  keys = require('assistant.mappings').default_mappings.dialog,
}

---@param self Assistant.Interface
function dialog_options.on_show(self)
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

local dialog = setmetatable({}, { __index = require('assistant.lib.interface').new(dialog_options) })

---@param content string|Assistant.Text
function dialog:display(content)
  self:show()
  if type(content) == 'string' then
    local lines = vim.split(content, '\n')
    local text = require('assistant.lib.text').new()
    for i, line in ipairs(lines) do
      text:append(line, 'AssistantParagraph')
      if i < #lines then
        text:nl()
      end
    end
    text:render(self.root.bufnr)
  else
    content:render(self.root.bufnr)
  end
end

return dialog
