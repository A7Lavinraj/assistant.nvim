local Canvas = require 'assistant.lib.canvas'
local Text = require 'assistant.lib.text'
local canvas = {}

canvas.standard = Canvas.new {
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
}

return canvas
