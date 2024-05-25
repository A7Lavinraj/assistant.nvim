local Renderer = {}

function Renderer.new()
  local self = setmetatable({}, { __index = Renderer })

  self.padding = 2
  self.buf = nil

  return self
end

function Renderer:init(buf)
  self.buf = buf

  return self
end

function Renderer:is_buf()
  if self.buf == nil then
    return false
  end

  return vim.api.nvim_buf_is_valid(self.buf)
end

function Renderer:text(text)
  if self:is_buf() then
    vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })

    vim.api.nvim_buf_set_lines(self.buf, 2, -1, false, {})

    for _, line in ipairs(text.lines) do
      vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, { string.rep(" ", self.padding) .. line.content })
      vim.api.nvim_buf_add_highlight(self.buf, -1, line.group, vim.api.nvim_buf_line_count(self.buf) - 1, 0, -1)
    end

    vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
  end
end

function Renderer:buttons(set)
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })

  local text = string.rep(" ", self.padding)

  for _, button in pairs(set.buttons) do
    text = text .. button.text .. string.rep(" ", set.gap)
  end

  vim.api.nvim_buf_set_lines(self.buf, 1, -1, false, { text })

  local start = self.padding
  local line = vim.api.nvim_buf_line_count(self.buf) - 1

  for _, button in pairs(set.buttons) do
    vim.api.nvim_buf_add_highlight(self.buf, -1, button.group, line, start, start + #button.text)
    start = start + #button.text + set.gap
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })
end

function Renderer:tests(tests, window)
  local text = require("assistant.ui.text").new():newline()

  for index, test in ipairs(tests) do
    text
      :append(
        string.format(
          "%s Testcase #%d: %s",
          (test.expand and test.expand == true and test.status ~= "RUNNING") and "" or "",
          index,
          test.status or "READY"
        ),
        test.group or "AssistantText"
      )
      :newline()

    if test.expand and test.expand == true and test.status ~= "RUNNING" then
      text:append("INPUT", "AssistantH2"):append("----------", "AssistantH2")

      for _, line in ipairs(vim.split(test.input, "\n")) do
        text:append(line, "AssistantText")
      end

      text:append("EXPECTED", "AssistantH2"):append("----------", "AssistantH2")

      for _, line in ipairs(vim.split(test.output, "\n")) do
        text:append(line, "AssistantText")
      end

      text:append("STDOUT", "AssistantH2"):append("----------", "AssistantH2")

      if test.stdout then
        for _, line in ipairs(vim.split(test.stdout, "\n")) do
          text:append(line, "AssistantText")
        end
      else
        text:append("NIL", "AssistantFadeText"):newline()
      end

      if test.stderr then
        text:append("STDERR", "AssistantH2"):append("----------", "AssistantH2")

        if test.stderr then
          for _, line in ipairs(vim.split(test.stderr, "\n")) do
            text:append(line, "AssistantText")
          end
        end
      end
    end
  end

  vim.schedule(function()
    self:text(text)
    vim.api.nvim_win_set_cursor(window.win, window.cpos)
  end)
end

return Renderer
