local Window = require 'assistant.lib.window'
local builtin_dialog_canvas = require 'assistant.builtins.canvas.dialog'
local state = require 'assistant.state'
local dialog = {}

---@param content string|Assistant.Text
---@param options? table
function dialog.display(content, options)
  local existing_dialog = state.get_global_key 'assistant_dialog'

  if existing_dialog then
    existing_dialog.window:close()
    state.set_global_key('assistant_dialog', nil)
  end

  options = options or {}

  dialog.window = Window.new {
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

  dialog.window:open()

  state.set_global_key('assistant_dialog', dialog)

  dialog.window:attach_autocmd('WinClosed', {
    callback = function()
      dialog.window:close()
    end,
  })

  dialog.window:set_win_config {
    title = string.format(' %s ', options.prompt or 'dialog'),
    title_pos = 'center',
  }

  dialog.window:set_buf_options {
    modifiable = false,
    filetype = 'assistant_dialog',
  }

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.dialog or {}) do
    for k, v in pairs(mappings) do
      dialog.window:set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
      }
    end
  end

  builtin_dialog_canvas.standard:set(dialog.window.bufnr, content)
end

return dialog
