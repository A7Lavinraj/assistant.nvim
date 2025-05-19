local Window = require 'assistant.lib.window'
local constants = require 'assistant.constants'
local state = require 'assistant.state'
local utils = require 'assistant.utils'

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

  return self
end

---@param content string
---@param options? table
---@param on_update fun(content: string)
function Patcher:update(content, options, on_update)
  options = options or {}
  local existing_patcher_window = state.get_local_key 'assistant-patcher-window'

  if existing_patcher_window then
    utils.remove_window(existing_patcher_window)
    state.set_local_key('assistant-patcher-window', nil)
    state.set_local_key('assistant-patcher-canvas', nil)
  end

  local patcher_window = Window.new {
    enter = true,
    zindex = 2,
    width = function(vw, _)
      return math.ceil(vw * constants.global_width) + 2
    end,
    height = function(_, vh)
      return math.ceil(vh * constants.global_height)
    end,
    col = function(vw, _)
      return math.floor((1 - constants.global_width) * 0.5 * vw) - 1
    end,
    row = function(_, vh)
      return math.floor((1 - constants.global_height) * 0.5 * vh)
    end,
  }

  utils.create_window(patcher_window)

  state.set_local_key('assistant-patcher-window', patcher_window)
  state.set_local_key('assistant-patcher-canvas', self.canvas)

  utils.create_autocmd('WinClosed', {
    callback = function()
      utils.remove_window(patcher_window)
    end,
  })

  utils.set_win_config(patcher_window.winid, {
    title = string.format(' %s ', options.self or 'Patcher'),
    title_pos = 'center',
  })

  utils.set_buf_option(patcher_window, 'filetype', 'assistant-patcher')

  utils.set_win_option(
    patcher_window,
    'winhighlight',
    table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ',')
  )

  utils.set_keymap {
    mode = 'n',
    lhs = '<cr>',
    rhs = function()
      local lines = vim.api.nvim_buf_get_lines(patcher_window.bufnr, 0, -1, false)

      utils.remove_window(patcher_window)
      on_update(table.concat(lines, '\n'))
    end,
    options = {
      buffer = patcher_window.bufnr,
    },
  }

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.patcher or {}) do
    for k, v in pairs(mappings) do
      utils.set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
        options = {
          buffer = patcher_window.bufnr,
        },
      }
    end
  end

  self.canvas:set(patcher_window.bufnr, content)
end

return Patcher
