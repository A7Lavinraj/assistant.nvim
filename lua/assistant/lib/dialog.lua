local Window = require 'assistant.lib.window'
local state = require 'assistant.state'

---@class Assistant.Dialog.Options
---@field canvas Assistant.Canvas

---@class Assistant.Dialog : Assistant.Dialog.Options
---@field window Assistant.Window
local Dialog = {}

---@param options Assistant.Dialog.Options
function Dialog.new(options)
  return setmetatable({}, {
    __index = Dialog,
  }):init(options)
end

---@param options Assistant.Dialog.Options
function Dialog:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  self.window = Window.new {
    enter = true,
    zindex = 2,
    width = function(vw, _)
      return math.ceil(vw * 0.85) + 3
    end,
    height = function(_, vh)
      return math.ceil(vh * 0.65)
    end,
    col = function(vw, _)
      return math.floor((1 - 0.85) * 0.5 * vw) - 1
    end,
    row = function(_, vh)
      return math.floor((1 - 0.65) * 0.5 * vh) - 1
    end,
  }

  return self
end

---@param content string|Assistant.Text
---@param options? table
function Dialog:display(content, options)
  options = options or {}
  self.window:open()

  state.set_local_key('assistant_dialog', self)

  self.window:attach_autocmd('WinClosed', {
    callback = function()
      self.window:close()
    end,
  })

  self.window:set_win_config {
    title = string.format(' %s ', options.prompt or 'dialog'),
    title_pos = 'center',
  }

  self.window:set_buf_options {
    modifiable = false,
    filetype = 'assistant_dialog',
  }

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.dialog or {}) do
    for k, v in pairs(mappings) do
      self.window:set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
      }
    end
  end

  self.canvas:set(self.window.bufnr, content)
end

return Dialog
