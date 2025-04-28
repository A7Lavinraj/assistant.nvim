local Canvas = require 'assistant.lib.canvas'
local Text = require 'assistant.lib.text'
local canvas = {}

canvas.standard = Canvas.new {
  fn = function(bufnr, content)
    if type(content) == 'string' then
      local lines = vim.split(content, '\n')
      local text = Text.new {}

      for i, line in ipairs(lines) do
        text:append(line, 'AssistantParagraph')
        if i < #lines then
          text:nl()
        end
      end

      text:render(bufnr)
    else
      content:render(bufnr)
    end
  end,
}

return canvas
