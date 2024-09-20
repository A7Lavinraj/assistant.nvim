local Window = require("assistant.ui.window")
local config = require("assistant.config")
local emit = require("assistant.emitter")
local rend = require("assistant.ui.renderer")
local tran = require("assistant.ui.transformer")
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

M.prompt = Window.new({
  h_ratio = 0.2,
  w_ratio = 0.2,
  h_align = "center",
  v_align = "center",
  enter = true,
  access = true,
  config = {
    relative = "editor",
    style = "minimal",
    border = config.border,
  },
  win_opts = {
    winhighlight = "NormalFloat:AssistantWindow,FloatBorder:AssistantWindowBorder",
  },
})

---@param tc_number number | nil
function M.preview(tc_number)
  rend(M.prev.buf, M.prev.access, tran.testcase(tc_number, M.prev.win))
end

function M.create()
  M.main:create()
  M.prev:create()
end

function M.remove()
  M.main:remove()
  M.prev:remove()
end

function M.toggle()
  if M.main.is_open and M.prev.is_open then
    M.remove()
  else
    M.create()
    emit("AssistantRender")
    emit("AssistantMainUIOpen")
  end
end

function M.resize()
  if M.main.is_open and M.prev.is_open then
    M.main:resize()
    M.prev:resize()
    M.prompt:resize()
  end
end

function M.quite(e)
  if e.buf ~= M.prompt.buf then
    M.remove()
  end
end

function M.render()
  rend(M.main.buf, M.main.access, tran.merge(tran.header(), tran.tests_list()))
end

return M
