local colors = require("assistant.ui.colors")
local mappings = require("assistant.mappings")
local prompt = require("assistant.ui.prompt")
local store = require("assistant.store")
local ui = require("assistant.ui")

local M = {}

function M.look(event, pattern, callback, custom_opts)
  local opts = { group = M.group, pattern = pattern, callback = callback }

  vim.api.nvim_create_autocmd(
    event,
    vim.tbl_deep_extend("force", opts, custom_opts or {})
  )
end

function M.load()
  M.group = vim.api.nvim_create_augroup("Assistant", { clear = true })

  M.look("User", "AssistantOpenWindow", mappings.load)
  M.look("User", "AssistantCompiled", function()
    ui:render_tab()
  end)
  M.look("User", "AssistantRender", function()
    ui:render_tab()
  end)

  M.look("ColorScheme", nil, colors.load)
  M.look("VimResized", nil, function()
    ui:resize()
  end)
  M.look(
    "QuitPre",
    nil,
    vim.schedule_wrap(function()
      if not ui:is_win() then
        ui:remove()
      end

      if not prompt:is_win() then
        prompt:close()
      end
    end)
  )
  M.look("BufEnter", "*.*", function(buf)
    if vim.fn.fnamemodify(buf.match, ":.") ~= store.FILENAME_WITH_EXTENSION then
      store:init()
    end
  end)
end

return M
