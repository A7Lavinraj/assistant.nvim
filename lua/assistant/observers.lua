local mappings = require("assistant.mappings")
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
  M.look("User", "AssistantMainUIOpen", mappings.load)
  M.look("ColorScheme", nil, themes.load)
  M.look("User", "AssistantRender", ui.render)
  M.look("VimResized", nil, ui.resize)
  M.look("QuitPre", nil, ui.quite)
  M.look("BufEnter", "*.*", function(buf)
    if vim.fn.fnamemodify(buf.match, ":.") ~= store.FILENAME_WITH_EXTENSION then
      store.init()
    end
  end)
  M.look("CursorMoved", nil, function(event)
    if ui.main:is_win() and ui.main.buf == event.buf then
      local current_line = vim.api.nvim_get_current_line()
      local number = tonumber(current_line:match("Testcase #(%d+): %a+"))

      if number then
        ui.preview(number)
      else
        ui.preview(nil)
      end
    end
  end)
end

return M
