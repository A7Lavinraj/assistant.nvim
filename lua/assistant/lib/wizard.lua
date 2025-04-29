local Window = require 'assistant.lib.window'
local config = require 'assistant.config'
local fs = require 'assistant.core.fs'
local state = require 'assistant.state'

---@class Assistant.Wizard.Options
---@field canvas Assistant.Canvas
---@field previewer Assistant.Previewer
---@field patcher Assistant.Patcher
---@field picker Assistant.Picker

---@class Assistant.Wizard : Assistant.Wizard.Options
---@field window Assistant.Window
local Wizard = {}

---@param options? Assistant.Wizard.Options
---@return Assistant.Wizard
function Wizard.new(options)
  return setmetatable({}, { __index = Wizard }):init(options)
end

---@param options? Assistant.Wizard.Options
---@return Assistant.Wizard
function Wizard:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  local layout_config = {
    width = 0.85,
    height = 0.65,
  }

  self.window = Window.new {
    enter = true,
    zindex = 1,
    width = function(vw, _)
      if not self.previewer then
        return math.ceil(vw * layout_config.width)
      end
      return math.ceil(vw * layout_config.width * 0.4)
    end,

    height = function(_, vh)
      return math.ceil(vh * layout_config.height)
    end,

    col = function(vw, _)
      if self.previewer then
        return math.floor((1 - layout_config.width) * vw * 0.5) - 1
      end
      return math.floor((1 - layout_config.width) * vw * 0.5)
    end,

    row = function(_, vh)
      return math.floor((1 - layout_config.height) * vh * 0.5) - 1
    end,
  }

  self.previewer.window.zindex = 1

  self.previewer.window.width = self.previewer.window.width
    or function(vw, _)
      return math.ceil(vw * layout_config.width * 0.6)
    end

  self.previewer.window.height = self.previewer.window.height
    or function(_, vh)
      return math.ceil(vh * layout_config.height)
    end

  self.previewer.window.col = self.previewer.window.col
    or function(vw, _)
      if self.previewer then
        return math.floor((1 - layout_config.width) * vw * 0.5) + math.ceil(vw * layout_config.width * 0.4) + 1
      end
      return math.floor((1 - layout_config.width) * vw * 0.5) + math.ceil(vw * layout_config.width * 0.4)
    end

  self.previewer.window.row = self.previewer.window.row
    or function(_, vh)
      return math.floor((1 - layout_config.height) * vh * 0.5) - 1
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

  local existing_wizard = state.get_local_key 'assistant_wizard'

  if existing_wizard then
    existing_wizard:hide()
    state.set_local_key('assistant_wizard', nil)
  end

  self.window:open()

  state.set_local_key('assistant_wizard', self)

  self.window:set_win_config {
    title = string.format(' Wizard - %s ', state.get_local_key 'filename'),
  }

  self.window:set_buf_options {
    modifiable = false,
    filetype = 'assistant_wizard',
  }

  self.window:set_win_options {
    cursorline = true,
  }

  self.window:attach_autocmd('WinClosed', {
    callback = function()
      self:hide()
    end,
  })

  self.window:attach_autocmd('CursorMoved', {
    callback = function()
      local testcase_ID = self.canvas:get(self.window.bufnr, self.window.winid)

      if testcase_ID then
        self.previewer:preview(testcase_ID)
      end
    end,
  })

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.wizard or {}) do
    for k, v in pairs(mappings) do
      self.window:set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
      }
    end
  end

  if self.previewer then
    self.previewer.window:open()

    state.set_local_key('assistant_previewer', self.previewer)

    self.previewer.window:attach_autocmd('WinClosed', {
      callback = function()
        self:hide()
      end,
    })

    for mode, mappings in pairs(require('assistant.mappings').default_mappings.previewer or {}) do
      for k, v in pairs(mappings) do
        self.previewer.window:set_keymap {
          mode = mode,
          lhs = k,
          rhs = v,
        }
      end
    end
  end

  self.previewer.window:set_win_config {
    title = ' Previewer ' .. (config.values.ui.diff_mode and '(Diff Mode ON) ' or '(Diff Mode OFF) '),
  }

  self.previewer.window:set_buf_options {
    modifiable = false,
    filetype = 'assistant_previewer',
  }

  self.canvas:set(self.window.bufnr)
end

function Wizard:hide()
  for _, window in ipairs { self.window, self.previewer.window } do
    window:close()
  end

  state.sync_and_clean()
end

---@return integer?
function Wizard:get_current()
  return self.canvas:get(self.window.bufnr, self.window.winid)
end

return Wizard
