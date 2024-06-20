local colors = require("assistant.ui.colors")
local mappings = require("assistant.mappings")
local store = require("assistant.store")
local ui = require("assistant.ui")

local M = {}

function M.look(event, pattern, callback, custom_opts)
  local opts = { group = M.group, pattern = pattern, callback = callback }

  vim.api.nvim_create_autocmd(event, vim.tbl_deep_extend("force", opts, custom_opts or {}))
end

function M.load()
  M.group = vim.api.nvim_create_augroup("Assistant", { clear = true })

  M.look("VimResized", nil, ui.resize_window)
  M.look({ "BufLeave", "BufHidden" }, nil, ui.close_window)
  M.look("User", "AssistantOpenWindow", mappings.load)
  M.look("User", "AssistantRender", ui.render_tab)
  M.look("User", "AssistantRenderStart", ui.write_start)
  M.look("User", "AssistantRenderEnd", ui.write_stop)
  M.look("BufEnter", "*.*", function(buf)
    if vim.fn.fnamemodify(buf.match, ":.") ~= store.FILENAME_WITH_EXTENSION then
      store.init()
    end
  end)
  M.look("User", "AssistantCompiled", ui.render_tab)
  M.look("ColorScheme", nil, colors.load)
end

return M
