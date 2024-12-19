local Text = require("assistant.ui.text")
local config = require("assistant.config")
local state = require("assistant.state")
local ui = require("assistant.ui")
local utils = require("assistant.utils")
local luv = vim.uv or vim.loop
local icons = config.options.ui.icons
local success = icons.success or ""
local failure = icons.failure or ""
local unknown = icons.unknown or ""
local frames = icons.loading or { "󰸴", "󰸵", "󰸸", "󰸷", "󰸶" }
local frame_id = 1
local M = {}
M.timer = luv.new_timer()

---@param str string
---@return string
function M.center(str)
  local width = math.floor(ui.actions.conf.width * 0.5)
  return string.rep(" ", width - math.ceil(#str * 0.5) - 1) .. str
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
  if not ui.actions:is_buf() then
    return
  end

  luv.timer_start(
    M.timer,
    0,
    200,
    vim.schedule_wrap(function()
      utils.render(ui.actions.buf, Text.new():append(M.center("COMPILATION " .. frames[frame_id]), "AssistantYellow"))
      frame_id = frame_id % #frames + 1
      vim.api.nvim_command("redraw")
    end)
  )
end

M.compilation_finish = vim.schedule_wrap(function(status)
  if not ui.actions:is_buf() then
    return
  end

  luv.timer_stop(M.timer)

  if status.code ~= 0 then
    local content = Text.new()

    for _, line in ipairs(vim.split(status.err or "", "\n")) do
      content:append(line, "AssistantDimText"):nl()
    end

    ui.popup_show(content)
  end

  local content = Text.new()

  if status.code == 0 then
    content:append(M.center("COMPILATION " .. success), "AssistantGreen")
  else
    content:append(M.center("COMPILATION " .. failure), "AssistantRed")
  end

  utils.render(ui.actions.buf, content)
end)

M.execution_status = vim.schedule_wrap(function()
  if not ui.actions:is_buf() then
    return
  end

  local status = Text.new()
  local tests = state.get_all_tests()

  if not tests then
    return
  end

  status:append(string.rep(" ", math.floor(ui.actions.conf.width * 0.5) - math.ceil((2 * #tests) * 0.5) - 3), "Nontext")

  for _, test in pairs(tests or {}) do
    if test.status == nil then
      status:append(unknown, "AssistantText")
    elseif test.status == "ACCEPTED" then
      status:append(success, "AssistantGreen")
    else
      status:append(failure, "AssistantRed")
    end
  end

  utils.render(ui.actions.buf, status)
  vim.api.nvim_command("redraw")
end)

return M
