local Canvas = require 'assistant.lib.canvas'
local Previewer = require 'assistant.lib.previewer'
local Text = require 'assistant.lib.text'
local config = require 'assistant.config'
local previewer = {}

previewer.standard = Previewer.new {
  canvas = Canvas.new {
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
          text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantFailure')
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
          text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantFailure')
        end
      end

      if testcase.stdout and #testcase.stdout ~= 0 then
        text:append('Stdout', 'AssistantHeading'):nl(2)

        if config.values.ui.diff_mode then
          for _, line in ipairs(require('assistant.algos.diff').get_higlighted_text(testcase.output, testcase.stdout)) do
            if vim.tbl_isempty(line or {}) then
              text:nl()
            else
              text:append(line.str, line.hl)
            end
          end
        else
          for _, line in ipairs(utils.slice_first_n_lines(testcase.stdout, 100)) do
            if line then
              text:append(line, 'AssistantParagraph'):nl()
            end
          end

          text:nl()
          local _, cnt = string.gsub(testcase.stdout or '', '\n', '')

          if cnt > 100 then
            text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantFailure')
          end
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
          text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantFailure')
        end
      end

      text:render(bufnr)
    end,
  },
}

return previewer
