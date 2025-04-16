local Window = require 'assistant.lib.window'
local picker_options = {}
picker_options.width = 0.3
picker_options.height = 0
picker_options.root = Window.new {
  name = 'picker',
  enter = true,
  width = 1,
  height = 1,
  col = (1 - picker_options.width) * 0.5,
  row = 0,
  title = ' Picker ',
  title_pos = 'center',
  bo = {
    modifiable = false,
    filetype = 'assistant_picker',
  },
  wo = {
    cursorline = true,
    winhighlight = table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ','),
  },
  keys = require('assistant.mappings').default_mappings.picker,
}

---@param self Assistant.Interface
function picker_options.on_show(self)
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

local picker = setmetatable({}, { __index = require('assistant.lib.interface').new(picker_options) })

---@param items string[]
---@param on_choice fun(item?: string)
function picker:select(items, on_choice)
  local text = require('assistant.lib.text').new()
  self.root.height = 0
  self.root.height_delta = math.min(#items, 5)
  self.on_choice = on_choice
  self:show()

  for i, line in ipairs(items) do
    text:append(line, 'AssistantParagraph')

    if i < #items then
      text:nl()
    end
  end

  text:render(self.root.bufnr)
end

return picker
