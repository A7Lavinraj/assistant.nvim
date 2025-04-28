local Window = require 'assistant.lib.window'
local state = require 'assistant.state'

---@class Assistant.Patcher.Options
---@field canvas Assistant.Canvas

---@class Assistant.Patcher : Assistant.Patcher.Options
local Patcher = {}

---@param options Assistant.Patcher.Options
function Patcher.new(options)
  return setmetatable({}, {
    __index = Patcher,
  }):init(options)
end

---@param options Assistant.Patcher.Options
function Patcher:init(options)
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

---@param content string
---@param options? table
---@param on_update fun(content: string)
function Patcher:update(content, options, on_update)
  local existing_patcher = state.get_global_key 'assistant_patcher'

  if existing_patcher then
    existing_patcher.window:close()
    state.set_global_key('assistant_patcher', nil)
  end

  options = options or {}

  self.window:open()

  state.set_global_key('assistant_patcher', self)

  self.window:attach_autocmd('WinClosed', {
    callback = function()
      self.window:close()
    end,
  })

  self.window:set_win_config {
    title = string.format(' %s ', options.self or 'patcher'),
    title_pos = 'center',
  }

  self.window:set_buf_options {
    filetype = 'assistant_patcher',
  }

  self.window:set_keymap {
    mode = 'n',
    lhs = '<cr>',
    rhs = function()
      local lines = vim.api.nvim_buf_get_lines(self.window.bufnr, 0, -1, false)

      self.window:close()

      on_update(table.concat(lines, '\n'))
    end,
  }

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.patcher or {}) do
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

return Patcher
