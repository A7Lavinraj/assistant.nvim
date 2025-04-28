local Text = require 'assistant.lib.text'
local state = require 'assistant.state'
local actions = {}

---@return number?
local function get_current_test_number()
  ---@type Assistant.Wizard
  local existing_wizard = state.get_global_key 'assistant_wizard'

  if
    not (existing_wizard and existing_wizard.window.bufnr and vim.api.nvim_buf_is_valid(existing_wizard.window.bufnr))
  then
    return
  end

  return existing_wizard:get_current()
end

function actions.close_current()
  local match = string.match(vim.bo.filetype, 'assistant_%w+')

  if match then
    local existing_match = state.get_global_key(match)

    if existing_match then
      existing_match.window:close()
    end
  end
end

function actions.focus_wizard()
  local existing_wizard = state.get_global_key 'assistant_wizard'

  if existing_wizard and existing_wizard.window.winid and vim.api.nvim_win_is_valid(existing_wizard.window.winid) then
    vim.fn.win_gotoid(existing_wizard.window.winid)
  end
end

function actions.focus_previewer()
  local existing_previewer = state.get_global_key 'assistant_previewer'

  if
    existing_previewer
    and existing_previewer.window.winid
    and vim.api.nvim_win_is_valid(existing_previewer.window.winid)
  then
    vim.fn.win_gotoid(existing_previewer.window.winid)
  end
end

function actions.run_testcases()
  local processor = require 'assistant.core.processor'
  local tests = state.get_global_key 'tests'
  local selected = {}

  for i, test in ipairs(tests or {}) do
    if test.selected then
      table.insert(selected, i)
    end
  end

  if vim.tbl_isempty(selected) then
    local test_ID = get_current_test_number()
    if test_ID then
      processor.run_tests { test_ID }
    end
  else
    processor.run_tests(selected)
  end
end

function actions.toggle_cur_selection()
  local test_ID = get_current_test_number()

  if test_ID then
    local test = state.get_global_key('tests')[test_ID]
    test.selected = not test.selected

    vim.schedule(function()
      state.get_global_key('assistant_wizard').canvas:set(state.get_global_key('assistant_wizard').window.bufnr)
    end)
  end
end

function actions.toggle_all_selection()
  local tests = state.get_global_key 'tests'
  local all_selected = true

  for _, test in ipairs(tests or {}) do
    if not test.selected then
      all_selected = false
      break
    end
  end

  local selected_ids = {}

  if all_selected then
    for i = 1, #tests do
      table.insert(selected_ids, i)
      tests[i].selected = false
    end
  else
    for i = 1, #tests do
      if not tests[i].selected then
        table.insert(selected_ids, i)
        tests[i].selected = true
      end
    end
  end

  vim.schedule(function()
    state.get_global_key('assistant_wizard').canvas:set(state.get_global_key('assistant_wizard').window.bufnr)
  end)
end

function actions.add_test()
  table.insert(state.get_global_key 'tests', { input = '', output = '' })
  vim.schedule(function()
    state.get_global_key('assistant_wizard').canvas:set(state.get_global_key('assistant_wizard').window.bufnr)
  end)
end

function actions.remove_tests()
  local tests = state.get_global_key 'tests'
  local selected = {}

  for test_id, test in ipairs(tests or {}) do
    if test.selected then
      table.insert(selected, test_id)
    end
  end

  if vim.tbl_isempty(selected) then
    local test_id = get_current_test_number()

    if test_id then
      table.insert(selected, test_id)
    end
  end

  table.sort(selected, function(a, b)
    return a > b
  end)

  for _, test_ID in ipairs(selected) do
    table.remove(tests, test_ID)
  end

  vim.schedule(function()
    state.get_global_key('assistant_wizard').canvas:set(state.get_global_key('assistant_wizard').window.bufnr)
  end)
end

function actions.edit_test()
  require('assistant.picker').select({ 'input', 'output' }, { prompt = 'field' }, function(choice)
    local test_ID = get_current_test_number()

    if not test_ID then
      return
    end

    local test = state.get_global_key('tests')[test_ID]
    require('assistant.prompt').update(test[choice] or '', { prompt = choice }, function(content)
      state.get_global_key('tests')[test_ID][choice] = content
    end)
  end)
end

function actions.which_key()
  local text = Text.new {}
  local mappings = require('assistant.mappings').default_mappings
  local gap = 5
  local mode_map = {
    n = 'Normal',
    i = 'Insert',
    v = 'Visual',
  }
  text:append('Press following described keys to execute corresponding action', 'AssistantBorder'):nl(2)
  for interface, mapping in pairs(mappings) do
    text:append(string.rep(' ', 15) .. interface:upper() .. string.rep(' ', 15), 'AssistantTitle'):nl()
    for mode, keys in pairs(mapping) do
      for k, v in pairs(keys) do
        text
          :append('  ', 'AssistantBorder')
          :append(mode_map[mode] .. string.rep(' ', gap), 'AssistantBorder')
          :append('  ', 'AssistantHeading')
          :append(k .. string.rep(' ', 2 * gap - #k), 'AssistantHeading')
          :append(' 󱐌 ', 'String')
          :append(v:get_name(), 'String')
          :nl()
      end
    end
    text:nl(2)
  end
  require('assistant.dialog').display(text, { prompt = 'which key' })
end

return require('assistant.lib.action').transform_mod(actions)
