local Window = require 'assistant.lib.window'
local builtin_prompt_canvas = require 'assistant.builtins.canvas.prompt'
local state = require 'assistant.state'
local prompt = {}

---@param content string
---@param options? table
---@param on_update fun(content: string)
function prompt.update(content, options, on_update)
  local existing_prompt = state.get_global_key 'assistant_prompt'

  if existing_prompt then
    existing_prompt.window:close()
    state.set_global_key('assistant_prompt', nil)
  end

  options = options or {}

  prompt.window = Window.new {
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

  prompt.window:open()

  state.set_global_key('assistant_prompt', prompt)

  prompt.window:attach_autocmd('WinClosed', {
    callback = function()
      prompt.window:close()
    end,
  })

  prompt.window:set_win_config {
    title = string.format(' %s ', options.prompt or 'prompt'),
    title_pos = 'center',
  }

  prompt.window:set_buf_options {
    filetype = 'assistant_prompt',
  }

  prompt.window:set_keymap {
    mode = 'n',
    lhs = '<cr>',
    rhs = function()
      local lines = vim.api.nvim_buf_get_lines(prompt.window.bufnr, 0, -1, false)

      prompt.window:close()

      on_update(table.concat(lines, '\n'))
    end,
  }

  for mode, mappings in pairs(require('assistant.mappings').default_mappings.prompt or {}) do
    for k, v in pairs(mappings) do
      prompt.window:set_keymap {
        mode = mode,
        lhs = k,
        rhs = v,
      }
    end
  end

  builtin_prompt_canvas.standard:set(prompt.window.bufnr, content)
end

return prompt
