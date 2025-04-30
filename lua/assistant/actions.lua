local Text = require 'assistant.lib.text'
local state = require 'assistant.state'
local utils = require 'assistant.utils'
local actions = {}

---@return number?
local function get_cur_testcase_ID()
  local panel_window = state.get_local_key 'assistant-panel-window' ---@type Assistant.Window
  local panel_canvas = state.get_local_key 'assistant-panel-canvas' ---@type Assistant.Canvas

  if not (panel_window and panel_window.bufnr and vim.api.nvim_buf_is_valid(panel_window.bufnr)) then
    return
  end

  return panel_canvas:get(panel_window.bufnr, panel_window.winid)
end

function actions.close_current()
  local match = string.match(vim.bo.filetype, '^[^-]+-(.+)$')

  if match then
    if vim.tbl_contains({ 'panel', 'previewer' }, match) then
      for _, window in ipairs {
        state.get_local_key 'assistant-panel-window',
        state.get_local_key 'assistant-previewer-window',
      } do
        utils.remove_window(window)
      end
    else
      utils.remove_window(state.get_local_key(string.format('assistant-%s-window', match)))
    end
  end
end

function actions.focus_panel()
  local panel_window = state.get_local_key 'assistant-panel-window'

  if panel_window and panel_window.winid and vim.api.nvim_win_is_valid(panel_window.winid) then
    vim.fn.win_gotoid(panel_window.winid)
  end
end

function actions.focus_previewer()
  local previewer_window = state.get_local_key 'assistant-previewer-window'

  if previewer_window and previewer_window.winid and vim.api.nvim_win_is_valid(previewer_window.winid) then
    vim.fn.win_gotoid(previewer_window.winid)
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
    local panel_window = state.get_local_key 'assistant-panel-window'
    local panel_canvas = state.get_local_key 'assistant-panel-canvas'
    testcase.selected = not testcase.selected

    vim.schedule(function()
      panel_canvas:set(panel_window.bufnr)
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

  local panel_window = state.get_local_key 'assistant-panel-window'
  local panel_canvas = state.get_local_key 'assistant-panel-canvas'

  vim.schedule(function()
    panel_canvas:set(panel_window.bufnr)
  end)
end

function actions.create_new_testcase()
  local panel_window = state.get_local_key 'assistant-panel-window'
  local panel_canvas = state.get_local_key 'assistant-panel-canvas'

  table.insert(state.get_global_key 'tests', { input = '', output = '' })

  vim.schedule(function()
    panel_canvas:set(panel_window.bufnr)
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

  local panel_window = state.get_local_key 'assistant-panel-window'
  local panel_canvas = state.get_local_key 'assistant-panel-canvas'

  vim.schedule(function()
    panel_canvas:set(panel_window.bufnr)
  end)
end

function actions.patch_testcase()
  require('assistant.builtins.__picker').standard:pick({ 'input', 'output' }, { prompt = 'field' }, function(choice)
    local testcase_ID = get_cur_testcase_ID()

    if not testcase_ID then
      return
    end

    local testcases = state.get_global_key 'tests'

    require('assistant.builtins.__patcher').standard:update(
      testcases[testcase_ID][choice] or '',
      { prompt = choice },
      function(content)
        testcases[testcase_ID][choice] = content
      end
    )
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

  require('assistant.builtins.__dialog').standard:display(text, { prompt = 'which key' })
end

return require('assistant.lib.action').transform_mod(actions)
