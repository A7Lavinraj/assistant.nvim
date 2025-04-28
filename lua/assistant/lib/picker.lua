local Window = require 'assistant.lib.window'
local state = require 'assistant.state'

---@class Assistant.Picker.Options
---@field canvas Assistant.Canvas

---@class Assistant.Picker : Assistant.Picker.Options
---@field window Assistant.Window
local Picker = {}

---@param options Assistant.Picker.Options
function Picker.new(options)
  return setmetatable({}, {
    __index = Picker,
  }):init(options)
end

---@param options Assistant.Picker.Options
function Picker:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  self.window = Window.new {
    enter = true,
    zindex = 3,
    width = function(vw, _)
      return math.ceil(vw * 0.3)
    end,
    height = function()
      return 5
    end,
    col = function(vw, _)
      return math.floor((1 - 0.3) * 0.5 * vw)
    end,
    row = function()
      return 0
    end,
  }

  return self
end

---@generic T
---@param items T[]
---@param options table
---@param on_choice fun(item: T)
function Picker:pick(items, options, on_choice)
  local existing_picker = state.get_global_key 'assistant_picker'

  if existing_picker then
    existing_picker.window:close()
    state.set_global_key('assistant_picker', nil)
  end

  options = options or {}

  self.window = Window.new {
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

  self.window:open()

  state.set_global_key('assistant_picker', self)

  self.window:attach_autocmd('WinClosed', {
    callback = function()
      self.window:close()
    end,
  })

  self.window:set_win_config {
    title = string.format(' %s ', options.prompt or 'picker'),
    title_pos = 'center',
  }

  self.window:set_buf_options {
    modifiable = false,
    filetype = 'assistant_picker',
  }

  self.window:set_win_options {
    cursorline = true,
  }

  self.window:set_keymap {
    mode = 'n',
    lhs = '<cr>',
    rhs = function()
      local current_line = vim.api.nvim_get_current_line()

      self.window:close()

      on_choice(current_line)
    end,
  }

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.picker or {}) do
    for k, v in pairs(mappings) do
      self.window:set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
      }
    end
  end

  self.canvas:set(self.window.bufnr, items)
end

return Picker
