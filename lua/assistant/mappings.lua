local actions = require 'assistant.actions'
local config = require 'assistant.config'
local mappings = {}

mappings.default_mappings = config.values.mappings
  or {
    picker = {
      n = {
        ['?'] = actions.show_help,
        ['q'] = actions.quit,
        ['<ESC>'] = actions.quit,
        ['<C-c>'] = actions.quit,
        ['<CR>'] = actions.picker_select,
      },
    },
    wizard = {
      n = {
        ['?'] = actions.show_help,
        ['q'] = actions.quit,
        ['<ESC>'] = actions.quit,
        ['<C-c>'] = actions.quit,
        ['r'] = actions.run_tests,
        ['s'] = actions.toggle_test_selection,
        ['a'] = actions.toggle_all_test_selection,
        ['c'] = actions.add_test,
        ['d'] = actions.remove_tests,
        ['e'] = actions.edit_test,
      },
    },
    dialog = {
      n = {
        ['?'] = actions.show_help,
        ['q'] = actions.quit,
        ['<ESC>'] = actions.quit,
        ['<C-c>'] = actions.quit,
      },
    },
    editor = {
      n = {
        ['?'] = actions.show_help,
        ['q'] = actions.quit,
        ['<ESC>'] = actions.quit,
        ['<C-c>'] = actions.quit,
        ['<CR>'] = actions.save_prompt_content,
      },
    },
  }

return mappings
