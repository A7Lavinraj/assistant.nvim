local actions = require 'assistant.actions'
local config = require 'assistant.config'
local mappings = {}

mappings.default_mappings = vim.tbl_deep_extend('force', {
  picker = {
    n = {
      ['?'] = actions.which_key,
      ['q'] = actions.close_current,
      ['<ESC>'] = actions.close_current,
      ['<C-c>'] = actions.close_current,
      ['<CR>'] = actions.picker_select,
    },
  },
  wizard = {
    n = {
      ['?'] = actions.which_key,
      ['q'] = actions.close_current,
      ['<ESC>'] = actions.close_current,
      ['<C-c>'] = actions.close_current,
      ['r'] = actions.run_testcases,
      ['s'] = actions.toggle_cur_selection,
      ['a'] = actions.toggle_all_selection,
      ['c'] = actions.create_new_testcase,
      ['d'] = actions.remove_testcases,
      ['e'] = actions.patch_testcase,
      ['<C-l>'] = actions.focus_previewer,
    },
  },
  previewer = {
    n = {
      ['?'] = actions.which_key,
      ['q'] = actions.close_current,
      ['<ESC>'] = actions.close_current,
      ['<C-c>'] = actions.close_current,
      ['<C-h>'] = actions.focus_wizard,
    },
  },
  dialog = {
    n = {
      ['?'] = actions.which_key,
      ['q'] = actions.close_current,
      ['<ESC>'] = actions.close_current,
      ['<C-c>'] = actions.close_current,
    },
  },
  patcher = {
    n = {
      ['?'] = actions.which_key,
      ['q'] = actions.close_current,
      ['<ESC>'] = actions.close_current,
      ['<C-c>'] = actions.close_current,
    },
  },
}, config.values.mappings or {})

return mappings
