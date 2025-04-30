local Window = require 'assistant.lib.window'
local state = require 'assistant.state'
local utils = require 'assistant.utils'

---@class Assistant.Dialog.Options
---@field canvas Assistant.Canvas

---@class Assistant.Dialog : Assistant.Dialog.Options
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

  return self
end

---@param content string|Assistant.Text
---@param options? table
function Dialog:display(content, options)
  options = options or {}

  local existing_dialog_window = state.get_local_key 'assistant-dialog-window'

  if existing_dialog_window then
    utils.remove_window(existing_dialog_window)
    state.set_local_key('assistant-dialog-window', nil)
    state.set_local_key('assistant-dialog-canvas', nil)
  end

  local dialog_window = Window.new {
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
      return math.floor((1 - 0.65) * 0.5 * vh)
    end,
  }

  utils.create_window(dialog_window)

  state.set_local_key('assistant-dialog-window', dialog_window)
  state.set_local_key('assistant-dialog-canvas', self.canvas)

  utils.create_autocmd('WinClosed', {
    buffer = dialog_window.bufnr,
    callback = function()
      utils.remove_window(dialog_window)
    end,
  })

  utils.set_win_config(dialog_window.winid, {
    title = string.format(' %s ', options.prompt or 'dialog'),
    title_pos = 'center',
  })

  utils.set_buf_option(dialog_window, 'modifiable', false)
  utils.set_buf_option(dialog_window, 'filetype', 'assistant-dialog')

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.dialog or {}) do
    for k, v in pairs(mappings) do
      utils.set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
        options = {
          buffer = dialog_window.bufnr,
        },
      }
    end
  end

  self.canvas:set(dialog_window.bufnr, content)
end

return Dialog
