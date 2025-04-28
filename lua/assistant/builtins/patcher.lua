local Canvas = require 'assistant.lib.canvas'
local Patcher = require 'assistant.lib.patcher'
local Text = require 'assistant.lib.text'
local patcher = {}

patcher.standard = Patcher.new {
  canvas = Canvas.new {
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
  },
}

return patcher
