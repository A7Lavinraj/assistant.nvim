local Window = require 'assistant.lib.window'
local builtin_picker_canvas = require 'assistant.builtins.canvas.picker'
local state = require 'assistant.state'
local picker = {}

---@generic T
---@param items T[]
---@param options table
---@param on_choice fun(item: T)
function picker.select(items, options, on_choice)
  local existing_picker = state.get_global_key 'assistant_picker'

  if existing_picker then
    existing_picker.window:close()
    state.set_global_key('assistant_picker', nil)
  end

  options = options or {}

  picker.window = Window.new {
    enter = true,
    zindex = 3,
    width = function(vw, _)
      return math.ceil(vw * 0.3)
    end,
    height = function()
      return math.min(5, #items)
    end,
    col = function(vw, _)
      return math.floor((1 - 0.3) * 0.5 * vw)
    end,
    row = function()
      return 0
    end,
  }

  picker.window:open()

  state.set_global_key('assistant_picker', picker)

  picker.window:attach_autocmd('WinClosed', {
    callback = function()
      picker.window:close()
    end,
  })

  picker.window:set_win_config {
    title = string.format(' %s ', options.prompt or 'picker'),
    title_pos = 'center',
  }

  picker.window:set_buf_options {
    modifiable = false,
    filetype = 'assistant_picker',
  }

  picker.window:set_win_options {
    cursorline = true,
  }

  picker.window:set_keymap {
    mode = 'n',
    lhs = '<cr>',
    rhs = function()
      local current_line = vim.api.nvim_get_current_line()

      picker.window:close()

      on_choice(current_line)
    end,
  }

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.picker or {}) do
    for k, v in pairs(mappings) do
      picker.window:set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
      }
    end
  end

  builtin_picker_canvas.standard:set(picker.window.bufnr, items)
end

return picker
