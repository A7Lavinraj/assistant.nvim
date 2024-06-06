local mappings = require("assistant.mappings")
local tabs = require("assistant.ui.tabs")
local window_main = require("assistant.ui.window").new()
require("assistant.ui.colors").load()

local M = {}

function M.open()
  window_main:create_window()
  mappings(tabs, window_main)
  window_main.buttonset:click(window_main.state.tab + 1)
  tabs[window_main.state.tab + 1](window_main)
end

function M.close()
  window_main:delete_window()
end

function M.toggle()
  if window_main.is_open then
    M.close()
  else
    M.open()
  end
end

return M
