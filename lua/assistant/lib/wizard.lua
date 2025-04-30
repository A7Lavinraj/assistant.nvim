local Window = require 'assistant.lib.window'
local fs = require 'assistant.core.fs'
local state = require 'assistant.state'
local utils = require 'assistant.utils'

---@class Assistant.Wizard.Options
---@field width number
---@field height number
---@field panel Assistant.Panel
---@field previewer Assistant.Previewer

---@class Assistant.Wizard : Assistant.Wizard.Options
local Wizard = {}

---@param options Assistant.Wizard.Options
function Wizard.new(options)
  return setmetatable({}, {
    __index = Wizard,
  }):init(options)
end

---@param options Assistant.Wizard.Options
function Wizard:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  return self
end

function Wizard:show()
  state.set_local_key('filename', vim.fn.expand '%:t:r')
  state.set_local_key('filetype', vim.bo.filetype)
  state.set_local_key('extension', vim.fn.expand '%:e')
  local filepath = fs.get_state_filepath()

  if filepath then
    local bytes = fs.read(filepath)
    local parsed = vim.json.decode(bytes or '{}')

    for k, v in pairs(parsed) do
      state.set_global_key(k, v)
    end
  end

  if not state.get_global_key 'tests' then
    state.set_global_key('tests', {})
  end

  utils.remove_window(state.get_local_key 'assistant-panel-window')
  utils.remove_window(state.get_local_key 'assistant-previewer-window')
  state.set_local_key('assistant-panel-window', nil)
  state.set_local_key('assistant-previewer-window', nil)
  state.set_local_key('assistant-panel-canvas', nil)
  state.set_local_key('assistant-previewer-canvas', nil)

  self.panel_window = Window.new {
    enter = true,
    zindex = 1,
    width = function(vw, _)
      return math.ceil(vw * self.width * (1 - self.previewer.width))
    end,
    height = function(_, vh)
      return math.ceil(vh * self.height)
    end,
    col = function(vw, _)
      return math.floor((1 - self.width) * vw * 0.5) - 1
    end,
    row = function(_, vh)
      return math.floor((1 - self.height) * vh * 0.5)
    end,
  }

  self.previewer_window = Window.new {
    zindex = 1,
    width = function(vw, _)
      return math.ceil(vw * self.width * self.previewer.width)
    end,
    height = function(_, vh)
      return math.ceil(vh * self.height)
    end,
    col = function(vw, _)
      return math.floor((1 - self.width) * vw * 0.5) + math.ceil(vw * self.width * (1 - self.previewer.width)) + 1
    end,
    row = function(_, vh)
      return math.floor((1 - self.height) * vh * 0.5)
    end,
  }

  utils.create_window(self.panel_window)
  utils.create_window(self.previewer_window)
  state.set_local_key('assistant-panel-window', self.panel_window)
  state.set_local_key('assistant-previewer-window', self.previewer_window)
  state.set_local_key('assistant-panel-canvas', self.panel.canvas)
  state.set_local_key('assistant-previewer-canvas', self.previewer.canvas)

  utils.set_win_config(self.panel_window.winid, {
    title = {
      { ' Panel', 'AssistantTitle' },
      { string.format(' (%s) ', state.get_local_key 'filename' or '?'), 'AssistantParagraph' },
    },
  })
  utils.set_win_config(self.previewer_window.winid, {
    title = {
      { ' Previewer', 'AssistantTitle' },
      {
        string.format(' (%s) ', require('assistant.config').values.ui.diff_mode and 'DIFF MODE ON' or 'DIFF MODE OFF'),
        require('assistant.config').values.ui.diff_mode and 'AssistantSuccess' or 'AssistantFailure',
      },
    },
  })

  utils.set_win_option(
    self.panel_window,
    'winhighlight',
    table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ',')
  )
  utils.set_win_option(
    self.previewer_window,
    'winhighlight',
    table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ',')
  )

  utils.set_buf_option(self.panel_window, 'modifiable', false)
  utils.set_buf_option(self.panel_window, 'filetype', 'assistant-panel')
  utils.set_buf_option(self.previewer_window, 'modifiable', false)
  utils.set_buf_option(self.previewer_window, 'filetype', 'assistant-previewer')

  utils.set_win_option(self.panel_window, 'cursorline', true)

  utils.create_autocmd('WinClosed', {
    buffer = self.panel_window.bufnr,
    callback = function()
      self:hide()
    end,
  })

  utils.create_autocmd('CursorMoved', {
    buffer = self.panel_window.bufnr,
    callback = function()
      local testcase_ID = self.panel.canvas:get(self.panel_window.bufnr, self.panel_window.winid)

      if testcase_ID then
        self.previewer.canvas:set(self.previewer_window.bufnr, state.get_global_key('tests')[testcase_ID])
      end
    end,
  })

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.panel or {}) do
    for k, v in pairs(mappings) do
      utils.set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
        options = {
          buffer = self.panel_window.bufnr,
        },
      }
    end
  end

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.previewer or {}) do
    for k, v in pairs(mappings) do
      utils.set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
        options = {
          buffer = self.previewer_window.bufnr,
        },
      }
    end
  end

  self.panel.canvas:set(self.panel_window.bufnr)
end

function Wizard:hide()
  utils.remove_window(self.panel_window)
  utils.remove_window(self.previewer_window)
  state.sync_and_clean()
end

return Wizard
