local interface_actions = require 'assistant.actions.interface'
local actions = {}

---@return number?
local function get_current_test_number()
  local wizard = require 'assistant.interfaces.wizard'
  if
    not (
      wizard.root.winid and vim.api.nvim_win_is_valid(wizard.root.winid) or vim.api.nvim_buf_is_valid(wizard.root.bufnr)
    )
  then
    return
  end
  local cursor_position = vim.api.nvim_win_get_cursor(wizard.root.winid)
  local current_line = vim.api.nvim_buf_get_lines(wizard.root.bufnr, cursor_position[1] - 1, cursor_position[1], false)
  return tonumber(current_line[1]:match '^%s*.+%s*Testcase #(%d+)')
end

function actions.picker_select()
  local picker = require 'assistant.interfaces.picker'
  local bufnr = picker.root.bufnr
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    local selection = vim.api.nvim_get_current_line()
    picker:hide()
    picker.on_choice(selection)
  end
end

function actions.show_details()
  local testID = get_current_test_number()
  if testID then
    require('assistant.interfaces.wizard'):render_details(testID)
  end
end

actions.quit = interface_actions.hide_current + interface_actions.focus_wizard

function actions.run_tests()
  local processor = require 'assistant.core.processor'
  local tests = require('assistant.state').get_global_key 'tests'
  local selected = {}

  for i, test in ipairs(tests or {}) do
    if test.selected then
      table.insert(selected, i)
    end
  end

  if vim.tbl_isempty(selected) then
    local test_id = get_current_test_number()
    if test_id then
      processor.run_tests { test_id }
    end
  else
    processor.run_tests(selected)
  end
end

function actions.toggle_test_selection()
  local state = require 'assistant.state'
  local testID = get_current_test_number()
  if testID then
    local test = state.get_global_key('tests')[testID]
    test.selected = not test.selected
    vim.schedule(function()
      require('assistant.interfaces.wizard'):render_tests()
    end)
  end
end

function actions.toggle_all_test_selection()
  local state = require 'assistant.state'
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
    require('assistant.interfaces.wizard'):render_tests()
  end)
end

function actions.add_test()
  table.insert(require('assistant.state').get_global_key 'tests', { input = '', output = '' })
  vim.schedule(function()
    require('assistant.interfaces.wizard'):render_tests()
  end)
end

function actions.remove_tests()
  local tests = require('assistant.state').get_global_key 'tests'
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

  for _, testID in ipairs(selected) do
    table.remove(tests, testID)
  end

  vim.schedule(function()
    require('assistant.interfaces.wizard'):render_tests()
  end)
end

function actions.edit_test()
  require('assistant.interfaces.picker'):select({ 'input', 'output' }, function(choice)
    local testID = get_current_test_number()
    if not testID then
      return
    end
    local test = require('assistant.state').get_global_key('tests')[testID]
    local text = require('assistant.lib.text').new()
    local editor = require 'assistant.interfaces.editor'
    local lines = vim.split(test[choice], '\n')
    for i, line in ipairs(lines) do
      text:append(line, 'AssistantParagraph')
      if i ~= #lines then
        text:nl()
      end
    end
    editor:show()
    editor.request_field = choice
    text:render(editor.root.bufnr)
  end)
end

function actions.save_prompt_content()
  local editor = require 'assistant.interfaces.editor'
  local state = require 'assistant.state'
  if not (editor.root.bufnr and vim.api.nvim_buf_is_valid(editor.root.bufnr)) then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(editor.root.bufnr, 0, -1, false)
  local testID = get_current_test_number()
  local test = state.get_global_key('tests')[testID]
  test[editor.request_field] = table.concat(lines, '\n')
  editor.request_field = nil
  actions.quit()
end

function actions.which_key()
  local text = require('assistant.lib.text').new()
  local mappings = require('assistant.mappings').default_mappings
  local dialog = require 'assistant.interfaces.dialog'
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
  dialog:display(text)
  dialog.root:set_window_config { title = ' Dialog - Which key ' }
end

return require('assistant.actions.meta').transform_mod(actions)
