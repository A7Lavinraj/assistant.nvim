local Window = require 'assistant.lib.window'
local wizard_options = {}
wizard_options.width = 0.85
wizard_options.height = 0.65
wizard_options.root = Window.new {
  name = 'task',
  enter = true,
  width = 0.4,
  height = 1,
  col = (1 - wizard_options.width) * 0.5,
  row = (1 - wizard_options.height) * 0.5,
  title = ' Tests ',
  title_pos = 'left',
  ref = Window.new {
    name = 'detail',
    width = 0.6,
    height = 1,
    col = wizard_options.width * 0.4,
    row = 0,
    col_delta = 2,
    border = 'rounded',
    title = ' Details ',
    title_pos = 'left',
    bo = {
      modifiable = false,
      filetype = 'assistant_wizard',
    },
    wo = {
      winblend = 0,
      winhighlight = table.concat({
        'Normal:AssistantNormal',
        'FloatBorder:AssistantBorder',
        'FloatTitle:AssistantTitle',
      }, ','),
    },
  },
  bo = {
    filetype = 'assistant_wizard',
    modifiable = false,
  },
  wo = {
    cursorline = true,
    winhighlight = table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ','),
  },
  keys = require('assistant.mappings').default_mappings.wizard,
}
---@param self Assistant.Interface
function wizard_options.be_show(self)
  local fs = require 'assistant.core.fs'
  local state = require 'assistant.state'
  local filename = vim.fn.expand '%:t:r'
  local root_dir = fs.find_or_make_root()
  local filepath = string.format('%s/.ast/%s.json', root_dir, filename)
  local bytes = fs.read(filepath)
  local parsed = vim.json.decode(bytes or '{}')
  for k, v in pairs(parsed) do
    state.set_global_key(k, v)
  end
  state.set_global_key('filename', filename)
  state.set_global_key('extension', vim.fn.expand '%:e')
  self.root.title = string.format(' Tests - %s ', filename == '' and '?' or filename)
end

---@param self table|Assistant.Interface
function wizard_options.on_show(self)
  local config = require 'assistant.config'
  self:each(function(root)
    vim.api.nvim_create_autocmd('WinClosed', {
      group = config.augroup,
      pattern = tostring(root.winid),
      callback = function()
        self:hide()
      end,
    })

    vim.api.nvim_create_autocmd('CursorMoved', {
      group = config.augroup,
      buffer = root.bufnr,
      callback = function()
        require('assistant.actions').show_details()
      end,
    })
  end)

  self:render_tests()
end

wizard_options.on_hide = require('assistant.state').sync_with_fs

local wizard = setmetatable({}, { __index = require('assistant.lib.interface').new(wizard_options) })

function wizard:render_tests()
  local text = require('assistant.lib.text').new()
  local tests = require('assistant.state').get_global_key 'tests'
  local get_group = setmetatable({ AC = 'AssistantSuccess', WA = 'AssistantFailure' }, {
    __index = function()
      return 'AssistantWarning'
    end,
  })
  local gap = 5
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
  text:render(self.root.bufnr)
end

---@param testID integer
function wizard:render_details(testID)
  local utils = require 'assistant.utils'
  local test = require('assistant.state').get_global_key('tests')[testID]
  local text = require('assistant.lib.text').new()

  if test.input and #test.input ~= 0 then
    text:append('Input', 'AssistantHeading'):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.input or '', 100)) do
      if line then
        text:append(line, 'AssistantParagraph'):nl()
      end
    end

    text:nl()
    local _, cnt = string.gsub(test.input or '', '\n', '')

    if cnt > 100 then
      text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
    end
  end

  if test.output and #test.output ~= 0 then
    text:append('Expect', 'AssistantHeading'):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.output or '', 100)) do
      if line then
        text:append(line, 'AssistantParagraph'):nl()
      end
    end

    text:nl()
    local _, cnt = string.gsub(test.output or '', '\n', '')

    if cnt > 100 then
      text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
    end
  end

  if test.stdout and #test.stdout ~= 0 then
    text:append('Stdout', 'AssistantHeading'):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.stdout, 100)) do
      if line then
        text:append(line, 'AssistantParagraph'):nl()
      end
    end

    text:nl()
    local _, cnt = string.gsub(test.stdout or '', '\n', '')

    if cnt > 100 then
      text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
    end
  end

  if test.stderr and #test.stderr ~= 0 then
    text:nl():append('Stderr', 'AssistantHeading'):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.stderr, 100)) do
      if line then
        text:append(line, 'AssistantParagraph'):nl()
      end
    end

    text:nl()
    local _, cnt = string.gsub(test.stderr or '', '\n', '')

    if cnt > 100 then
      text:append('-- REACHED MAXIMUM RENDER LIMIT --', 'AssistantParagraph')
    end
  end

  text:render(self.root.ref.bufnr)
end

return wizard
