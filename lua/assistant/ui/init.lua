local Text = require("assistant.ui.text")
local Window = require("assistant.ui.window")
local config = require("assistant.config")
local emit = require("assistant.emitter")
local rend = require("assistant.ui.renderer")
local store = require("assistant.store")
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
  h_ratio = 0.3,
  w_ratio = 0.2,
  h_align = "center",
  v_align = "center",
  enter = true,
  access = true,
  config = {
    relative = "editor",
    style = "minimal",
    border = config.border or "single",
  },
  win_opts = {
    winhighlight = "NormalFloat:AssistantWindow,FloatBorder:AssistantWindowBorder",
  },
})

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

function M.update_test()
  if M.prompt:is_buf() then
    store.PROBLEM_DATA["tests"][M.prompt.tc_number][M.prompt.field] =
        table.concat(vim.api.nvim_buf_get_lines(M.prompt.buf, 0, -1, false), "\n")
  end
end

function M.quite(e)
  if e.buf == M.prompt.buf then
    M.prompt:remove()
  else
    M.remove()
  end
end

function M.render()
  rend(M.main.buf, M.main.access, tran.merge(tran.header(), tran.tests_list()))
  store.CHECKPOINTS = {}

  if M.main:is_buf() then
    for i, line in ipairs(vim.api.nvim_buf_get_lines(M.main.buf, 0, -1, false)) do
      if line:match("Testcase #(%d+): %a+") then
        table.insert(store.CHECKPOINTS, i)
      end
    end
  end

  if #store.CHECKPOINTS ~= 0 and (not vim.api.nvim_get_current_line():match("Testcase #%d+: %a+")) then
    vim.api.nvim_win_set_cursor(M.main.win, { store.CHECKPOINTS[1], 1 })
  end
end

function M.preview(tc_number)
  rend(M.prev.buf, M.prev.access, tran.testcase(tc_number, M.prev.win))
end

function M.input(tc_number, field)
  M.prompt.tc_number = tc_number
  M.prompt.field = field
  M.prompt:create()
  local data = Text.new(0)
  local test = vim.split(store.PROBLEM_DATA["tests"][M.prompt.tc_number][M.prompt.field], "\n")

  if store.PROBLEM_DATA then
    for index, segment in ipairs(test) do
      data:append(segment, "AssistantText")

      if index ~= #test then
        data:nl()
      end
    end

    rend(M.prompt.buf, M.prompt.access, data)
  end

  M.prompt:on_key("n", "q", function()
    M.update_test()
    M.prompt:remove()
  end)
  M.prompt:on_key("n", "<esc>", function()
    M.update_test()
    M.prompt:remove()
  end)
end

return M
