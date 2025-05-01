local test = require 'mini.test'
local utils = require 'assistant.utils'

local T = test.new_set()

T['to_snake_case'] = function()
  local camel_case_to_snake = {
    { input = 'camelCase', expected = 'camel_case' },
    { input = 'PascalCase', expected = 'pascal_case' },
    { input = 'snake_case', expected = 'snake_case' },
    { input = 'already_Snake_Case', expected = 'already_snake_case' },
    { input = 'MixOfALLFormats123HTML', expected = 'mix_of_all_formats_123_html' },
    { input = 'HTMLParser', expected = 'html_parser' },
    { input = 'NASA', expected = 'nasa' },
    { input = 'snakeCaseWith123Numbers', expected = 'snake_case_with_123_numbers' },
    { input = '   trimmed  String   ', expected = 'trimmed_string' },
    { input = 'with  multiple     spaces', expected = 'with_multiple_spaces' },
    { input = '', expected = '' },
    { input = '12345', expected = '12345' },
    { input = 'This__Is__Weird', expected = 'this_is_weird' },
    { input = 'hello@world!', expected = 'helloworld' },
  }

  for _, case in ipairs(camel_case_to_snake) do
    test.expect.equality(utils.to_snake_case(case.input), case.expected)
  end
end

return T
