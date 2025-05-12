local Canvas = require 'assistant.lib.canvas'
local Panel = require 'assistant.lib.panel'
local Previewer = require 'assistant.lib.previewer'
local Text = require 'assistant.lib.text'
local Wizard = require 'assistant.lib.wizard'
local wizard = {}

function wizard.standard()
  Wizard.new({
    width = 0.85,
    height = 0.65,
    panel = Panel.new {
      canvas = Canvas.new {
        fn = function(bufnr, testcases)
          local text = Text.new {}
          local gap = 5
          local get_group = setmetatable({ AC = 'AssistantSuccess', WA = 'AssistantFailure' }, {
            __index = function()
              return 'AssistantWarning'
            end,
          })

          for i, testcase in ipairs(testcases or {}) do
            if testcase.selected then
              text:append(' ', 'AssistantFailure')
            else
              text:append('  ', 'AssistantParagraph')
            end

            text:append(string.format('Testcase #%d', i), 'AssistantParagraph')
            text:append(string.rep(' ', gap), 'AssistantParagraph')

            if testcase.status then
              text:append(testcase.status or 'UNKNOWN', get_group[testcase.status])
            end

            text:append(string.rep(' ', gap), 'AssistantParagraph')
            if testcase.time_taken then
              text:append(string.format('%.3f', testcase.time_taken or 0), 'AssistantParagraph')
            end

            if i < #testcases then
              text:nl()
            end
          end

          text:render(bufnr)
        end,
        gn = function(bufnr, winid)
          if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
            return nil
          end
          local cursor_position = vim.api.nvim_win_get_cursor(winid)
          local current_line = vim.api.nvim_buf_get_lines(bufnr, cursor_position[1] - 1, cursor_position[1], false)
          return tonumber(current_line[1]:match '^%s*.+%s*Testcase #(%d+)')
        end,
      },
    },
    previewer = Previewer.new {
      width = 0.6,
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

            if require('assistant.config').values.ui.diff_mode then
              for _, line in
                ipairs(require('assistant.algos.diff').get_higlighted_text(testcase.output, testcase.stdout))
              do
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
    },
  }):show()
end

return wizard
