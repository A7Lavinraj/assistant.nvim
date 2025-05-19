local Window = require 'assistant.lib.window'
local constants = require 'assistant.constants'
local state = require 'assistant.state'
local utils = require 'assistant.utils'

---@class Assistant.Terminal.Options
---@field command Assistant.Processor.Command

---@class Assistant.Terminal : Assistant.Terminal.Options
local Terminal = {}

---@param options Assistant.Terminal.Options
---@return Assistant.Terminal
function Terminal.new(options)
  return setmetatable({}, {
    __index = Terminal,
  }):init(options)
end

---@param options Assistant.Terminal.Options
---@return Assistant.Terminal
function Terminal:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  return self
end

function Terminal:spawn()
  local terminal_window = Window.new {
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

  utils.create_window(terminal_window)

  state.set_local_key('assistant-terminal-window', terminal_window)

  utils.create_autocmd('WinClosed', {
    buffer = terminal_window.bufnr,
    callback = function()
      utils.remove_window(terminal_window)
    end,
  })

  utils.set_win_config(terminal_window.winid, {
    title = string.format(' %s ', 'Terminal'),
    title_pos = 'center',
  })

  utils.set_buf_option(terminal_window, 'modifiable', false)
  utils.set_buf_option(terminal_window, 'filetype', 'assistant-dialog')

  utils.set_win_option(
    terminal_window,
    'winhighlight',
    table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ',')
  )

  ---@param command Assistant.Processor.Command
  ---@return string
  local function get_term_command(command)
    return (command.main or '') .. ' ' .. table.concat(command.args or {}, ' ')
  end

  vim.fn.execute(string.format('terminal %s', get_term_command(self.command)))
  vim.fn.execute 'startinsert'
end

return Terminal
