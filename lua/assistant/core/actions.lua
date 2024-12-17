local Text = require("assistant.ui.text")
local state = require("assistant.state")
local ui = require("assistant.ui")
local utils = require("assistant.utils")
local luv = vim.uv or vim.loop
local M = {}
M.frames = { "󰸴", "󰸵", "󰸸", "󰸷", "󰸶" }
M.frame_id = 1
M.timer = luv.new_timer()

---@param str string
---@return string
function M.center(str)
  local width = math.floor(ui.actions.conf.width * 0.5)
  return string.rep(" ", width - math.ceil(#str * 0.5)) .. str
end

---@param status string
---@return string
function M.get_color_on_status(status)
  if status == "RUNNING" then
    return "AssistantYellow"
  end

  if status == "ACCEPTED" then
    return "AssistantGreen"
  end

  return "AssistantRed"
end

function M.compilation_start()
  luv.timer_start(
    M.timer,
    0,
    200,
    vim.schedule_wrap(function()
      utils.render(
        ui.actions.buf,
        Text.new():append(M.center("COMPILATION " .. M.frames[M.frame_id]), "AssistantYellow")
      )
      M.frame_id = M.frame_id % #M.frames + 1
      vim.api.nvim_command("redraw")
    end)
  )
end

M.compilation_finish = vim.schedule_wrap(function()
  luv.timer_stop(M.timer)
  utils.render(ui.actions.buf, Text.new():append(M.center("COMPILATION "), "AssistantGreen"))
end)

M.execution_status = vim.schedule_wrap(function()
  local status = Text.new()
  local tests = state.get_all_tests()

  if not tests then
    return
  end

  for _ = 1, math.floor(ui.actions.conf.width * 0.5) - math.ceil((2 * #tests) * 0.5) - 2 do
    status:append("", "NonText")
  end

  for _, test in pairs(tests or {}) do
    local color = M.get_color_on_status(test.status)
    status:append((color == "AssistantGreen" and "" or ""), color)
  end

  utils.render(ui.actions.buf, status)
  vim.api.nvim_command("redraw")
end)

return M
