local AstText = require("assistant.ui.text")
local state = require("assistant.core.state")
local utils = require("assistant.utils")
local opts = require("assistant.config").opts

local AstRender = {}

local luv = vim.uv or vim.loop
local timer = luv.new_timer()
local frames = opts.ui.icons.loading_frames
local frame_id = 1
local success = opts.ui.icons.success
local failure = opts.ui.icons.failure
local unknown = opts.ui.icons.unknown

---@param layout Ast.Layout
function AstRender.new(layout)
  local self = setmetatable({}, { __index = AstRender })
  self.layout = layout
  return self
end

---@param buf integer
---@param text Ast.Text
function AstRender.render(buf, text)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if not text.lines then
    return
  end

  local lines = {}
  local modifiable = vim.bo[buf].modifiable

  if not modifiable and utils.is_buf(buf) then
    vim.bo[buf].modifiable = true
  end

  for _, row in pairs(text.lines) do
    local line = string.rep(" ", text.pd)

    for i, col in ipairs(row) do
      line = line .. col.str .. string.rep(" ", i == #row and 0 or 1)
    end

    table.insert(lines, line)
  end

  if utils.is_buf(buf) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  for cnt, row in ipairs(text.lines) do
    local offset = text.pd

    for _, col in ipairs(row) do
      vim.api.nvim_buf_add_highlight(buf, 0, col.hl, cnt - 1, offset, offset + #col.str)
      offset = offset + #col.str + 1
    end
  end

  if not modifiable and utils.is_buf(buf) then
    vim.bo[buf].modifiable = false
  end

  vim.cmd.redraw()
end

function AstRender:render_tasks()
  local name = state.get_problem_name()
  local tests = state.get_all_tests()
  local lines = AstText.new()
  lines:append("󰫍 ", "AstTextYellow"):append(name or "", "AstTextH1"):nl(2)

  for id, test in ipairs(tests or {}) do
    if test.checked then
      lines:append(" ", "AstTextP")
    else
      lines:append(" ", "AstTextP")
    end

    lines:append(string.format("Testcase #%d", id), "AstTextH1"):nl()
    lines:append("↳", "AstTextDim"):append("󰂓", "AstTextP")

    if test.status then
      lines:append(string.format("%s", test.status.text), test.status.hl)
    else
      lines:append("-", "AstTextP")
    end

    lines:append(" 󰔛", "AstTextP")

    if test.time_taken then
      lines:append(string.format("%.3f", test.time_taken), "AstTextP")
    else
      lines:append("-", "AstTextP")
    end

    if id ~= #tests then
      lines:nl(2)
    end
  end

  self.render(self.layout.pane_config.Tasks.buf, lines)
end

function AstRender:render_log(id)
  local test = state.get_test_by_id(id)
  local lines = AstText.new()

  if test.input and #test.input ~= 0 then
    lines:append("Input", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.input or "", 100)) do
      if line then
        lines:append(line, "AstTextP"):nl()
      end
    end

    lines:nl()
    local _, cnt = string.gsub(test.input or "", "\n", "")

    if cnt > 100 then
      lines:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  if test.output and #test.output ~= 0 then
    lines:append("Expect", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.output or "", 100)) do
      if line then
        lines:append(line, "AstTextP"):nl()
      end
    end

    lines:nl()
    local _, cnt = string.gsub(test.output or "", "\n", "")

    if cnt > 100 then
      lines:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  if test.stdout and #test.stdout ~= 0 then
    lines:append("Stdout", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.stdout, 100)) do
      if line then
        lines:append(line, "AstTextP"):nl()
      end
    end

    lines:nl()
    local _, cnt = string.gsub(test.stdout or "", "\n", "")

    if cnt > 100 then
      lines:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  if test.stderr and #test.stderr ~= 0 then
    lines:nl():append("Stderr", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.stderr, 100)) do
      if line then
        lines:append(line, "AstTextP"):nl()
      end
    end

    lines:nl()
    local _, cnt = string.gsub(test.stderr or "", "\n", "")

    if cnt > 100 then
      lines:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  self.render(self.layout.pane_config.Logs.buf, lines)
end

---@param test_id integer
function AstRender:render_io(test_id)
  local test = state.get_test_by_id(test_id)
  local lines = AstText.new()
  lines.pd = 0
  utils.io_to_text(lines, test.input, test.output)
  self.render(self.layout.pane_config.Edit.buf, lines)
end

function AstRender:compiling()
  if not timer then
    return
  end

  local lines = AstText.new()
  luv.timer_start(
    timer,
    0,
    200,
    vim.schedule_wrap(function()
      lines.lines = { {} }
      lines:append("COMPILATION ", "AstTextH1"):append(frames[frame_id], "AstTextYellow")
      frame_id = frame_id % #frames + 1
      self.render(self.layout.view.pane_config.Actions.buf, lines)
    end)
  )
end

---@param status {code:number,err:string}
function AstRender:compiled(status)
  local lines = AstText.new()

  if timer then
    luv.timer_stop(timer)
  end

  if status.code ~= 0 then
    for _, line in ipairs(vim.split(status.err or "", "\n")) do
      lines:append(line, "AstTextP"):nl()
    end

    self.layout.popup()
    self.render(self.layout.view.pane_config.Popup.buf, lines)
  end

  lines.lines = { {} }

  if status.code == 0 then
    lines:append("COMPILATION ", "AstTextH1"):append(type(success) == "string" and success or "", "AstTextGreen")
  else
    lines:append("COMPILATION ", "AstTextH1"):append(type(failure) == "string" and failure or "", "AstTextRed")
  end

  self.render(self.layout.view.pane_config.Actions.buf, lines)
end

function AstRender:executed()
  local lines = AstText.new()
  local tests = state.get_all_tests()

  if not tests then
    return
  end

  lines:append("VERDICTS ", "AstTextH1")

  for _, test in pairs(tests or {}) do
    if not test.status or test.status.text == "Skipped" then
      lines:append(type(unknown) == "string" and unknown or "", "AstTextH1")
    elseif test.status.text == "Accepted" then
      lines:append(type(success) == "string" and success or "", "AstTextGreen")
    else
      lines:append(type(failure) == "string" and failure or "", "AstTextRed")
    end
  end

  self.render(self.layout.view.pane_config.Actions.buf, lines)
end

return AstRender
