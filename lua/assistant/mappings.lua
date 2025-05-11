local actions = require 'assistant.actions'
local config = require 'assistant.config'
local mappings = {}

mappings.default_mappings = {
  picker = {
    n = {
      ['?'] = actions.which_key,
      ['q'] = actions.close_current,
      ['<ESC>'] = actions.close_current,
      ['<C-c>'] = actions.close_current,
      ['<CR>'] = actions.picker_select,
    },
  },
  panel = {
    n = {
      ['?'] = actions.which_key,
      ['q'] = actions.close_current,
      ['<ESC>'] = actions.close_current,
      ['<C-c>'] = actions.close_current,
      ['i'] = actions.run_interactive,
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
      ['<C-h>'] = actions.focus_panel,
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
}

if not vim.tbl_isempty(config.values.mappings or {}) then
  for window, map_group in pairs(config.values.mappings or {}) do
    for mode, mapping in pairs(map_group) do
      for k, v in pairs(mapping) do
        mappings.default_mappings[window][mode][k] = v
      end
    end
  end
end

return mappings
