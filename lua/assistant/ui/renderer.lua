local Renderer = {}

function Renderer.new()
  local self = setmetatable({}, { __index = Renderer })
  self.padding = 2
  self.bufnr = nil

  return self
end

function Renderer:init(opts)
  self.padding = opts.padding or self.padding
  self.bufnr = opts.bufnr

  return self
end

function Renderer:text(text)
  for _, line in ipairs(text.lines) do
    vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, { string.rep(" ", self.padding) .. line.content })
    vim.api.nvim_buf_add_highlight(self.bufnr, -1, line.group, vim.api.nvim_buf_line_count(self.bufnr) - 1, 0, -1)
  end
end

function Renderer:buttons(set)
  local text = string.rep(" ", self.padding)

  for _, button in pairs(set.buttons) do
    text = text .. button.text .. string.rep(" ", set.gap)
  end

  vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, { text })
  local start = self.padding
  local line = vim.api.nvim_buf_line_count(self.bufnr) - 1

  for _, button in pairs(set.buttons) do
    vim.api.nvim_buf_add_highlight(self.bufnr, -1, button.group, line, start, start + #button.text)
    start = start + #button.text + set.gap
  end
end

return Renderer
