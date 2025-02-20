local AstLayout = require("assistant.ui.layout")
local AstRunner = require("assistant.runner")
local AstText = require("assistant.ui.text")
local state = require("assistant.state")
local utils = require("assistant.utils")
local opt = require("assistant.config").opts

local M = setmetatable({}, {
  __index = setmetatable(AstText, {
    __index = setmetatable(AstRunner, {
      __index = AstLayout,
    }),
  }),
})

local layout_opts = {
  width = opt.ui.width,
  height = opt.ui.height,
  backdrop = opt.ui.backdrop,
  border = opt.ui.border,
  zindex = 1,
  pane_config = {
    Tasks = {
      style = "minimal",
      relative = "editor",
      width = 0.4,
      height = 1,
      dheight = -3,
      title = " Tasks " .. opt.ui.tasks.title_icon,
      enter = true,
    },
    Actions = {
      style = "minimal",
      relative = "editor",
      dheight = 1,
      width = 0.4,
      bottom = "Tasks",
      border = opt.ui.actions.border,
      title = " Actions " .. opt.ui.tasks.title_icon,
    },
    Logs = {
      style = "minimal",
      relative = "editor",
      width = 0.6,
      height = 1,
      right = "Tasks",
      border = opt.ui.logs.border,
      title = " Logs " .. opt.ui.tasks.title_icon,
    },
  },
}

layout_opts.on_attach = function(self)
  self:bind_cmd("WinClosed", function(event)
    if not event or not event.match then
      return
    end
    for _, config in pairs(self.pane_config) do
      if config.win == tonumber(event.match) then
        return self:close()
      end
    end
  end)

  self:bind_cmd("VimResized", function()
    self:resize()
  end)

  for name, config in pairs(self.pane_config) do
    if name ~= "Backdrop" then
      self:bind_key("q", function()
        self:close()
      end, { buffer = config.buf })
    end
  end
end

layout_opts.on_mount_end = function(self)
  local winhls = { "NormalFloat", "FloatBorder", "FloatTitle" }

  for name, config in pairs(self.pane_config) do
    local winhl = ""

    for index, hl in ipairs(winhls) do
      if index ~= 1 then
        winhl = winhl .. ","
      end

      winhl = winhl .. string.format("%s:Ast%s%s", hl, name, hl)
    end

    utils.wo(config.win, "winhighlight", winhl)
    utils.bo(config.buf, "modifiable", false)

    if name == "Tasks" then
      utils.wo(config.win, "cursorline", true)
    end

    if self.backdrop and name == "Backdrop" then
      utils.wo(config.win, "winblend", self.backdrop)
    end
  end

  self:bind_key("j", utils.next_test, { buffer = self.pane_config.Tasks.buf })

  self:bind_key("k", utils.prev_test, { buffer = self.pane_config.Tasks.buf })

  self:bind_key("r", function()
    self:push_unique()
  end, { buffer = self.pane_config.Tasks.buf })

  self:bind_cmd("CursorMoved", function()
    local line = vim.api.nvim_get_current_line()

    if line:match("^%s*.+%s*Testcase #%d+") then
      local id = tonumber(line:match("^%s*.+%s*Testcase #(%d+)"))
      self:render_log(id)
    end
  end, { buffer = self.pane_config.Tasks.buf })

  self:bind_cmd("BufWritePost", function()
    state.set_by_key("need_compilation", function()
      return true
    end)
  end)

  self:render_tasks()
  utils.next_test()
end

layout_opts.on_mount_start = state.update

AstLayout._init(M, layout_opts)
AstText._init(M)
AstRunner._init(M)

function M.toggle()
  if M.is_open then
    M:close()
  else
    M:open()
  end
end

---@param buf integer
function M:render(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if not self.lines then
    return
  end

  local lines = {}
  local access = vim.api.nvim_get_option_value("modifiable", { buf = buf })

  if not access then
    utils.bo(buf, "modifiable", true)
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

  if not access then
    utils.bo(buf, "modifiable", false)
  end
end

function M:render_tasks()
  local name = state.get_problem_name()
  local tests = state.get_all_tests()

  self.lines = { {} }

  self:append("󰫍", "AstTextDim"):append(name or "", "AstTextH1"):nl(2)

  for id, test in ipairs(tests or {}) do
    if test.checked then
      self:append(" ", "AstTextP")
    else
      self:append(" ", "AstTextP")
    end

    self:append(string.format("Testcase #%d", id), "AstTextH1"):nl()
    self
      :append("↳", "AstTextDim")
      :append("󰂓", "AstTextDim")
      :append(string.format("%s", test.status or "Pending"), "AstTextP")
      :append("󰔛", "AstTextDim")

    if test.time_taken then
      self:append(string.format("%.3f", test.time_taken), "AstTextP")
    else
      self:append("-", "AstTextP")
    end

    if id ~= #tests then
      self:nl(2)
    end
  end

  self:render(self.pane_config.Tasks.buf)
end

---@param id integer
function M:render_log(id)
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
    local _, cnt = string.gsub(test.stdout or "", "\n", "")

    if cnt > 100 then
      self:append("-- REACHED MAXIMUM RENDER LIMIT --", "AstTextDim")
    end
  end

  self:render(self.pane_config.Logs.buf)
end

return M
