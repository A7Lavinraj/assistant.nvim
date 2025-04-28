local Canvas = require 'assistant.lib.canvas'
local Picker = require 'assistant.lib.picker'
local Text = require 'assistant.lib.text'
local picker = {}

picker.standard = Picker.new {
  canvas = Canvas.new {
    fn = function(bufnr, items)
      local text = Text.new {}

      for i, line in ipairs(items) do
        text:append(line, 'AssistantParagraph')

        if i < #items then
          text:nl()
        end
      end

      text:render(bufnr)
    end,
  },
}

return picker
