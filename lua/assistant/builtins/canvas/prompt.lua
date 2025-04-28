local Canvas = require 'assistant.lib.canvas'
local Text = require 'assistant.lib.text'
local canvas = {}

canvas.standard = Canvas.new {
  fn = function(bufnr, content)
    local text = Text.new {}
    local lines = vim.split(content, '\n')

    for i, line in ipairs(lines) do
      text:append(line, 'AssistantParagraph')

      if i < #lines then
        text:nl()
      end
    end

    text:render(bufnr)
  end,
}

return canvas
