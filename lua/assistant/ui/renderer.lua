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
  end

  if self:is_buf() then
    vim.api.nvim_buf_set_lines(self.buf, 2, -1, false, {})
  end

  for _, line in pairs(text.lines) do
    if self:is_buf() then
      vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, { string.rep(" ", self.padding) .. line.content })
    end

    for _, hl in pairs(line.hl) do
      if self:is_buf() then
        vim.api.nvim_buf_add_highlight(
          self.buf,
          -1,
          hl.group,
          vim.api.nvim_buf_line_count(self.buf) - 1,
          hl.col_start,
          hl.col_end
        )
      end
    end
  end

  if self:is_buf() then
    vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
  end
end

function Renderer:buttons(set)
  if self:is_buf() then
    vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })
  end

  local text = string.rep(" ", self.padding)

  for _, button in pairs(set.buttons) do
    text = text .. button.text .. string.rep(" ", set.gap)
  end

  if self:is_buf() then
    vim.api.nvim_buf_set_lines(self.buf, 1, -1, false, { text })
  end

  local start = self.padding
  local line = vim.api.nvim_buf_line_count(self.buf) - 1

  for _, button in pairs(set.buttons) do
    if self:is_buf() then
      vim.api.nvim_buf_add_highlight(self.buf, -1, button.group, line, start, start + #button.text)
    end
    start = start + #button.text + set.gap
  end

  if self:is_buf() then
    vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })
  end
end

function Renderer:tests(tests, window)
  local text = require("assistant.ui.text").new():newline()

  for index, test in ipairs(tests) do
    local default =
      string.format("%s Testcase #%d: %s", test.expand == true and "" or "", index, test.status or "READY")

    text:append({
      content = (test.start_at and test.end_at)
          and (default .. string.format(" takes %.3f seconds", (test.end_at - test.start_at) / 1000))
        or default,
      hl = {
        {
          col_start = 0,
          col_end = #default + 2,
          group = test.group or "AssistantReady",
        },
        {
          col_start = #default + 2,
          col_end = -1,
          group = "AssistantFadeText",
        },
      },
    })

    text:newline()

    if test.expand and test.expand == true and test.status ~= "RUNNING" then
      text
        :append({
          content = " INPUT ",
          hl = {
            {
              col_start = 2,
              col_end = -1,
              group = "AssistantNote",
            },
          },
        })
        :newline()

      for _, line in ipairs(vim.split(test.input, "\n")) do
        text:append({
          content = line,
          hl = {
            {
              col_start = 0,
              col_end = -1,
              group = "AssistantText",
            },
          },
        })
      end

      text
        :append({
          content = " EXPECTED ",
          hl = {
            {
              col_start = 2,
              col_end = -1,
              group = "AssistantNote",
            },
          },
        })
        :newline()

      for _, line in ipairs(vim.split(test.output, "\n")) do
        text:append({
          content = line,
          hl = {
            {
              col_start = 0,
              col_end = -1,
              group = "AssistantText",
            },
          },
        })
      end

      if test.stdout then
        text
          :append({
            content = " STDOUT ",
            hl = {
              {
                col_start = 2,
                col_end = -1,
                group = "AssistantNote",
              },
            },
          })
          :newline()

        for _, line in ipairs(vim.split(test.stdout, "\n")) do
          text:append({
            content = line,
            hl = {
              {
                col_start = 0,
                col_end = -1,
                group = "AssistantText",
              },
            },
          })
        end
      end

      if test.stderr then
        text:append({
          content = " STDERR ",
          hl = {
            {
              col_start = 2,
              col_end = -1,
              group = "AssistantNote",
            },
          },
        })

        if test.stderr then
          for _, line in ipairs(vim.split(test.stderr, "\n")) do
            text:append({
              content = line,
              hl = {
                {
                  col_start = 0,
                  col_end = -1,
                  group = "AssistantText",
                },
              },
            })
          end
        end
      end
    end
  end

  vim.schedule(function()
    self:text(text)

    if self:is_buf() then
      if window.cpos[1] < vim.api.nvim_buf_line_count(window.buf) then
        vim.api.nvim_win_set_cursor(window.win, window.cpos)
      end
    end
  end)
end

return Renderer
