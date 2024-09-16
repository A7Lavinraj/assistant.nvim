local mappings = require("assistant.mappings")
local previewer = require("assistant.ui.previewer")
local prompt = require("assistant.ui.prompt")
local store = require("assistant.store")
local themes = require("assistant.ui.themes")
local ui = require("assistant.ui")

local M = {}

function M.look(event, pattern, callback, custom_opts)
  local opts = { group = M.group, pattern = pattern, callback = callback }
  vim.api.nvim_create_autocmd(event, vim.tbl_deep_extend("force", opts, custom_opts or {}))
end

function M.load()
  M.group = vim.api.nvim_create_augroup("Assistant", { clear = true })
  M.look("User", "AssistantOpenWindow", mappings.load)
  M.look("ColorScheme", nil, themes.load)
  M.look("User", "AssistantCompiled", function()
    ui:render()
  end)
  M.look("User", "AssistantRender", function()
    ui:render()
  end)
  M.look("VimResized", nil, function()
    ui:resize()
    prompt:resize()
    previewer:resize()
  end)
  M.look(
    "QuitPre",
    nil,
    vim.schedule_wrap(function()
      if not ui:is_win() then
        ui:remove()
        previewer:remove()
      end

      if not prompt:is_win() then
        prompt:close()
      end

      if not previewer:is_win() then
        previewer:remove()
      end
    end)
  )
  M.look("BufEnter", "*.*", function(buf)
    if vim.fn.fnamemodify(buf.match, ":.") ~= store.FILENAME_WITH_EXTENSION then
      store:init()
    end
  end)
  M.look("CursorMoved", nil, function(event)
    if ui:is_win() and ui.state.buf == event.buf then
      local current_line = vim.api.nvim_get_current_line()
      local number = tonumber(current_line:match("Testcase #(%d+): %a+"))

      if number then
        previewer:preview(number)
      else
        previewer:preview(nil)
      end
    end
  end)
end

return M
