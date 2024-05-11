local Renderer = {}

function Renderer.new()
  local self = setmetatable({}, { __index = Renderer })
  self.padding = 2
  self.buf = nil

  return self
end

function Renderer:init(opts)
  self.padding = opts.padding or self.padding
  self.buf = opts.bufnr

  return self
end

function Renderer:text(text)
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })
  for _, line in ipairs(text.lines) do
    vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, { string.rep(" ", self.padding) .. line.content })
    vim.api.nvim_buf_add_highlight(self.buf, -1, line.group, vim.api.nvim_buf_line_count(self.buf) - 1, 0, -1)
  end
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
end

function Renderer:buttons(set)
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })

  local text = string.rep(" ", self.padding)

  for _, button in pairs(set.buttons) do
    text = text .. button.text .. string.rep(" ", set.gap)
  end

  vim.api.nvim_buf_set_lines(self.buf, -1, -1, false, { text })

  local start = self.padding
  local line = vim.api.nvim_buf_line_count(self.buf) - 1

  for _, button in pairs(set.buttons) do
    vim.api.nvim_buf_add_highlight(self.buf, -1, button.group, line, start, start + #button.text)
    start = start + #button.text + set.gap
  end

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf })
end

return Renderer
