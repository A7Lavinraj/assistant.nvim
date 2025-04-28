local Canvas = require 'assistant.lib.canvas'
local Text = require 'assistant.lib.text'
local canvas = {}

canvas.standard = Canvas.new {
  fn = function(bufnr, testcase)
    local utils = require 'assistant.utils'
    local text = Text.new {}

    if testcase.input and #testcase.input ~= 0 then
      text:append('Input', 'AssistantHeading'):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(testcase.input or '', 100)) do
        if line then
          text:append(line, 'AssistantParagraph'):nl()
        end
      end

      text:nl()
      local _, cnt = string.gsub(testcase.input or '', '\n', '')

      if cnt > 100 then
        text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
      end
    end

    if testcase.output and #testcase.output ~= 0 then
      text:append('Expect', 'AssistantHeading'):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(testcase.output or '', 100)) do
        if line then
          text:append(line, 'AssistantParagraph'):nl()
        end
      end

      text:nl()
      local _, cnt = string.gsub(testcase.output or '', '\n', '')

      if cnt > 100 then
        text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
      end
    end

    if testcase.stdout and #testcase.stdout ~= 0 then
      text:append('Stdout', 'AssistantHeading'):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(testcase.stdout, 100)) do
        if line then
          text:append(line, 'AssistantParagraph'):nl()
        end
      end

      text:nl()
      local _, cnt = string.gsub(testcase.stdout or '', '\n', '')

      if cnt > 100 then
        text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
      end
    end

    if testcase.stderr and #testcase.stderr ~= 0 then
      text:nl():append('Stderr', 'AssistantHeading'):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(testcase.stderr, 100)) do
        if line then
          text:append(line, 'AssistantParagraph'):nl()
        end
      end

      text:nl()
      local _, cnt = string.gsub(testcase.stderr or '', '\n', '')

      if cnt > 100 then
        text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
      end
    end

    text:render(bufnr)
  end,
}

return canvas
