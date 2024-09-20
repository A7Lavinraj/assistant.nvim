local Window = require("assistant.ui.window")
local config = require("assistant.config")
local M = {}

M.main = Window.new({
  h_ratio = 0.7,
  w_ratio = 0.3,
  h_align = "start",
  v_align = "center",
  enter = true,
  access = false,
  config = {
    relative = "editor",
    style = "minimal",
    border = config.border,
  },
  win_opts = {
    winhighlight = "NormalFloat:AssistantWindow,FloatBorder:AssistantWindowBorder",
  },
})

M.prev = Window.new({
  h_ratio = 0.7,
  w_ratio = 0.3,
  h_align = "end",
  v_align = "center",
  enter = false,
  access = false,
  config = {
    relative = "editor",
    style = "minimal",
    border = config.border,
  },
  win_opts = {
    winhighlight = "NormalFloat:AssistantWindow,FloatBorder:AssistantWindowBorder",
  },
})

function M.toggle()
  if M.main.is_open and M.prev.is_open then
    M.main:remove()
    M.prev:remove()
  else
    M.main:create()
    M.prev:create()
  end
end

return M
