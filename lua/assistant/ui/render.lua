local AstText = require("assistant.ui.text")
local state = require("assistant.state")
local utils = require("assistant.utils")

local AstRender = {}

---@param layout Ast.Layout
function AstRender.new(layout)
  local self = setmetatable({}, { __index = setmetatable(AstText, { __index = AstRender }) })

  self.layout = layout
  self.pd = 2

  return self
end

---@param buf integer
function AstRender:render(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if not self.lines then
    return
  end

  local lines = {}
  local modifiable = vim.bo[buf].modifiable

  if not modifiable then
    vim.bo[buf].modifiable = true
  end

  for _, row in pairs(self.lines) do
    local line = string.rep(" ", self.pd)

    for i, col in ipairs(row) do
      line = line .. col.str .. string.rep(" ", i == #row and 0 or 1)
    end

    table.insert(lines, line)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for cnt, row in ipairs(self.lines) do
    local offset = self.pd

    for _, col in ipairs(row) do
      vim.api.nvim_buf_add_highlight(buf, 0, col.hl, cnt - 1, offset, offset + #col.str)
      offset = offset + #col.str + 1
    end
  end

  if not modifiable then
    vim.bo[buf].modifiable = false
  end

  vim.cmd.redraw()
end

function AstRender:render_tasks()
  local name = state.get_problem_name()
  local tests = state.get_all_tests()

  self.lines = { {} }

  self:append("󰫍 ", "AstTextYellow"):append(name or "", "AstTextH1"):nl(2)

  for id, test in ipairs(tests or {}) do
    if test.checked then
      self:append(" ", "AstTextP")
    else
      self:append(" ", "AstTextP")
    end

    self:append(string.format("Testcase #%d", id), "AstTextH1"):nl()
    self:append("↳", "AstTextDim"):append("󰂓", "AstTextP")

    if test.status then
      self:append(string.format("%s", test.status.text), test.status.hl)
    else
      self:append("-", "AstTextP")
    end

    self:append(" 󰔛", "AstTextP")

    if test.time_taken then
      self:append(string.format("%.3f", test.time_taken), "AstTextP")
    else
      self:append("-", "AstTextP")
    end

    if id ~= #tests then
      self:nl(2)
    end
  end

  self:render(self.layout.pane_config.Tasks.buf)
end

function AstRender:render_log(id)
  local test = state.get_test_by_id(id)

  self.lines = { {} }

  if test.input then
    self:append("Input", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.input or "", 100)) do
      if line then
        self:append(line, "AstTextP"):nl()
      end
    end

    self:nl()
    local _, cnt = string.gsub(test.input or "", "\n", "")

    if cnt > 100 then
      self:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  if test.output then
    self:append("Expect", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.output or "", 100)) do
      if line then
        self:append(line, "AstTextP"):nl()
      end
    end

    self:nl()
    local _, cnt = string.gsub(test.output or "", "\n", "")

    if cnt > 100 then
      self:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  if test.stdout then
    self:append("Stdout", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.stdout, 100)) do
      if line then
        self:append(line, "AstTextP"):nl()
      end
    end

    self:nl()
    local _, cnt = string.gsub(test.stdout or "", "\n", "")

    if cnt > 100 then
      self:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  if test.stderr then
    self:nl():append("Stderr", "AstTextH1"):nl(2)

    for _, line in ipairs(utils.slice_first_n_lines(test.stderr, 100)) do
      if line then
        self:append(line, "AstTextP"):nl()
      end
    end

    self:nl()
    local _, cnt = string.gsub(test.stderr or "", "\n", "")

    if cnt > 100 then
      self:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  self:render(self.layout.pane_config.Logs.buf)
end

---@param test_id integer
function AstRender:render_io(test_id)
  local test = state.get_test_by_id(test_id)
  self.lines = { {} }
  self.pd = 0

  utils.io_to_text(self, test.input, test.output)

  self:render(self.layout.pane_config.Edit.buf)
  self.pd = 2
end

return AstRender
