local Text = require("assistant.ui.text")
local store = require("assistant.store")

---@class AssistantRender
---@field view AssistantView
local AssistantRender = {}

function AssistantRender.new(view)
  local self = setmetatable({}, { __index = AssistantRender })
  self.view = view
  return self
end

---@param buf number
---@param text AssistantText
function AssistantRender.render(buf, text)
  local lines = {}
  local access = vim.api.nvim_get_option_value("modifiable", { buf = buf })

  for _, row in pairs(text.lines) do
    local line = string.rep(" ", text.padding)

    for i, col in pairs(row) do
      line = line .. col.str .. string.rep(" ", i == #row and 0 or 1)
    end

    table.insert(lines, line)
  end

  if buf and vim.api.nvim_buf_is_valid(buf) then
    if not access then
      vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  for cnt, row in pairs(text.lines) do
    local offset = text.padding

    for _, col in pairs(row) do
      if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_add_highlight(buf, -1, col.hl, cnt - 1, offset, offset + #col.str)
      end

      offset = offset + #col.str + 1
    end
  end

  if buf and vim.api.nvim_buf_is_valid(buf) then
    if not access then
      vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    end
  end
end

function AssistantRender:home()
  local content = Text.new()

  if not store.PROBLEM_DATA then
    store.PROBLEM_DATA = {}
  end

  if not store.PROBLEM_DATA["tests"] then
    store.PROBLEM_DATA["tests"] = {}
  end

  for i, test in ipairs(store.PROBLEM_DATA["tests"]) do
    content:append(string.format("testcase #%d ", i), "AssistantText")

    if test.status == "PASSED" then
      content:append(test.status, "AssistantGreen")
    end

    if test.status == "FAILED" then
      content:append(test.status, "AssistantRed")
    end

    if test.status == "RUNNING" or test.status == "COMPILING" then
      content:append(test.status, "AssistantYellow")
    end

    if i ~= #store.PROBLEM_DATA["tests"] then
      content:nl()
    end
  end

  self.render(self.view[1][1].buf, content)
end

function AssistantRender:stats()
  local content = Text.new()

  if store.is_server_running then
    content:append("SERVER ", "AssistantGreen"):nl(2)
  else
    content:append("SERVER ", "AssistantRed"):nl(2)
  end

  self.render(self.view[2][1].buf, content)
end

---@param id number?
function AssistantRender:input(id)
  if not id then
    return
  end

  local content = Text.new()
  local tc = store.PROBLEM_DATA["tests"][id]
  if tc.input then
    content:append("Input", "AssistantH1"):nl(2)

    for _, line in ipairs(vim.split(tc.input or "", "\n")) do
      if line then
        content:append(line, "AssistantText"):nl()
      end
    end
  end

  if tc.output then
    content:append("Expect", "AssistantH1"):nl(2)

    for _, line in ipairs(vim.split(tc.output or "", "\n")) do
      if line then
        content:append(line, "AssistantText"):nl()
      end
    end
  end

  self.render(self.view[1][2].buf, content)
end

---@param id number?
function AssistantRender:output(id)
  if not id then
    return
  end

  local content = Text.new()
  local tc = store.PROBLEM_DATA["tests"][id]

  if tc.stdout and tc.stdout ~= "" then
    content:append("Stdout", "AssistantH1"):nl(2)

    for _, line in ipairs(vim.split(tc.stdout, "\n")) do
      if line then
        content:append(line, "AssistantText"):nl()
      end
    end
  end

  if tc.stderr and tc.stderr ~= "" then
    content:nl():append("Stderr", "AssistantH1"):nl(2)

    for _, line in ipairs(vim.split(tc.stderr, "\n")) do
      if line then
        content:append(line, "AssistantText"):nl()
      end
    end
  end

  self.render(self.view[2][2].buf, content)
end

return AssistantRender
