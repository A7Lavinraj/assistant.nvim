local Canvas = require 'assistant.lib.canvas'
local Text = require 'assistant.lib.text'
local Wizard = require 'assistant.lib.wizard'
local builtin_patcher = require 'assistant.builtins.patcher'
local builtin_picker = require 'assistant.builtins.picker'
local builtin_previewer = require 'assistant.builtins.previewer'
local state = require 'assistant.state'
local wizard = {}

function wizard.standard()
  Wizard.new({
    canvas = Canvas.new {
      fn = function(bufnr)
        local text = Text.new {}
        local tests = state.get_global_key 'tests'
        local gap = 5
        local get_group = setmetatable({ AC = 'AssistantSuccess', WA = 'AssistantFailure' }, {
          __index = function()
            return 'AssistantWarning'
          end,
        })

        for i, test in ipairs(tests or {}) do
          if test.selected then
            text:append(' ', 'AssistantFailure')
          else
            text:append('  ', 'AssistantParagraph')
          end

          text:append(string.format('Testcase #%d', i), 'AssistantParagraph')
          text:append(string.rep(' ', gap), 'AssistantParagraph')

          if test.status then
            text:append(test.status or 'UNKNOWN', get_group[test.status])
          end

          text:append(string.rep(' ', gap), 'AssistantParagraph')
          if test.time_taken then
            text:append(string.format('%.3f', test.time_taken or 0), 'AssistantParagraph')
          end

          if i < #tests then
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
    previewer = builtin_previewer.standard,
    picker = builtin_picker.standard,
    patcher = builtin_patcher.standard,
  }):show()
end

return wizard
