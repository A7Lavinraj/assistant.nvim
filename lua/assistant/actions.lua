local Text = require 'assistant.lib.text'
local state = require 'assistant.state'
local actions = {}

---@return number?
local function get_cur_testcase_ID()
  ---@type Assistant.Wizard
  local existing_wizard = state.get_local_key 'assistant_wizard'

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
    local existing_match = state.get_local_key(match)

    if existing_match then
      existing_match.window:close()
    end
  end
end

function actions.focus_wizard()
  local existing_wizard = state.get_local_key 'assistant_wizard'

  if existing_wizard and existing_wizard.window.winid and vim.api.nvim_win_is_valid(existing_wizard.window.winid) then
    vim.fn.win_gotoid(existing_wizard.window.winid)
  end
end

function actions.focus_previewer()
  local existing_previewer = state.get_local_key 'assistant_previewer'

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
  local testcases = state.get_global_key 'tests'
  local selected = {}

  for i, testcase in ipairs(testcases or {}) do
    if testcase.selected then
      table.insert(selected, i)
    end
  end

  if vim.tbl_isempty(selected) then
    local testcase_ID = get_cur_testcase_ID()
    if testcase_ID then
      processor.run_testcases { testcase_ID }
    end
  else
    processor.run_testcases(selected)
  end
end

function actions.toggle_cur_selection()
  local testcase_ID = get_cur_testcase_ID()

  if testcase_ID then
    local testcase = state.get_global_key('tests')[testcase_ID]
    testcase.selected = not testcase.selected

    vim.schedule(function()
      state.get_local_key('assistant_wizard').canvas:set(state.get_local_key('assistant_wizard').window.bufnr)
    end)
  end
end

function actions.toggle_all_selection()
  local testcases = state.get_global_key 'tests'
  local all_selected = true

  for _, testcase in ipairs(testcases or {}) do
    if not testcase.selected then
      all_selected = false
      break
    end
  end

  local selected_ids = {}

  if all_selected then
    for i = 1, #testcases do
      table.insert(selected_ids, i)
      testcases[i].selected = false
    end
  else
    for i = 1, #testcases do
      if not testcases[i].selected then
        table.insert(selected_ids, i)
        testcases[i].selected = true
      end
    end
  end

  vim.schedule(function()
    state.get_local_key('assistant_wizard').canvas:set(state.get_local_key('assistant_wizard').window.bufnr)
  end)
end

function actions.create_new_testcase()
  table.insert(state.get_global_key 'tests', { input = '', output = '' })
  vim.schedule(function()
    state.get_local_key('assistant_wizard').canvas:set(state.get_local_key('assistant_wizard').window.bufnr)
  end)
end

function actions.remove_testcases()
  local testcases = state.get_global_key 'tests'
  local selected = {}

  for testcase_ID, testcase in ipairs(testcases or {}) do
    if testcase.selected then
      table.insert(selected, testcase_ID)
    end
  end

  if vim.tbl_isempty(selected) then
    local testcase_ID = get_cur_testcase_ID()

    if testcase_ID then
      table.insert(selected, testcase_ID)
    end
  end

  table.sort(selected, function(a, b)
    return a > b
  end)

  for _, testcase_ID in ipairs(selected) do
    table.remove(testcases, testcase_ID)
  end

  vim.schedule(function()
    state.get_local_key('assistant_wizard').canvas:set(state.get_local_key('assistant_wizard').window.bufnr)
  end)
end

function actions.patch_testcase()
  local existing_wizard = state.get_local_key 'assistant_wizard'
  existing_wizard.picker:pick({ 'input', 'output' }, { prompt = 'field' }, function(choice)
    local testcase_ID = get_cur_testcase_ID()

    if not testcase_ID then
      return
    end

    local testcases = state.get_global_key 'tests'
    existing_wizard.patcher:update(testcases[testcase_ID][choice] or '', { prompt = choice }, function(content)
      testcases[testcase_ID][choice] = content
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

  require('assistant.builtins.dialog').standard:display(text, { prompt = 'which key' })
end

return require('assistant.lib.action').transform_mod(actions)
