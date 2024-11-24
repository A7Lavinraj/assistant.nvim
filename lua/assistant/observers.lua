local Render = require("assistant.ui.render")
local maps = require("assistant.mappings")
local ui = require("assistant.ui")
local render = Render.new(ui.view)

local M = {}

function M.look(event, pattern, callback, custom_opts)
  local opts = { group = M.group, pattern = pattern, callback = callback }
  vim.api.nvim_create_autocmd(event, vim.tbl_deep_extend("force", opts, custom_opts or {}))
end

function M.load()
  M.group = vim.api.nvim_create_augroup("Assistant", { clear = true })
  M.look("VimResized", nil, ui.resize)
  M.look("User", "AssistantViewOpen", function()
    maps.load()
    render:home()
    render:stats()
  end)
  M.look("User", "AssistantViewClose", maps.unload)
  M.look("CursorMoved", nil, function()
    local current_line = vim.api.nvim_get_current_line()
    local number = tonumber(current_line:match("Testcase #(%d+)%s+"))

    if number then
      render:input(number)
      render:output(number)
    end
  end)
end

return M
