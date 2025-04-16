---@alias Assistant.Text.Line { str: string, hl: string }

---@class Assistant.Text.Options
---@field left_margin integer

---@class Assistant.Text : Assistant.Text.Options
---@field lines Assistant.Text.Line[][]
local Text = {}

---@param options? Assistant.Text.Options
---@return Assistant.Text
function Text.new(options)
  return setmetatable({}, { __index = Text }):init(options)
end

---@param options? Assistant.Text.Options
function Text:init(options)
  options = options or {}
  self.left_margin = options.left_margin or 0
  self.lines = { {} }
  return self
end

---@param count integer|nil
function Text:nl(count)
  for _ = 1, (count or 1) do
    table.insert(self.lines, {})
  end

  return self
end

---@param str string
---@param hl string
function Text:append(str, hl)
  table.insert(self.lines[#self.lines], { str = str, hl = hl })
  return self
end

---@param bufnr integer
function Text:render(bufnr)
  local ns = require('assistant.config').namespace
  local start_line = 0

  local was_modifiable = vim.bo[bufnr].modifiable

  if not was_modifiable then
    vim.bo[bufnr].modifiable = true
  end

  local virt_lines = {}
  for _, line in ipairs(self.lines) do
    local text = string.rep(' ', self.left_margin)
    for _, segment in ipairs(line) do
      text = text .. segment.str
    end
    table.insert(virt_lines, text)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, virt_lines)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for i, line in ipairs(self.lines) do
    local col = self.left_margin
    for _, segment in ipairs(line) do
      if segment.hl and segment.hl ~= '' then
        vim.api.nvim_buf_set_extmark(bufnr, ns, start_line + i - 1, col, {
          end_col = col + #segment.str,
          hl_group = segment.hl,
        })
      end
      col = col + #segment.str
    end
  end

  if not was_modifiable then
    vim.bo[bufnr].modifiable = false
  end
end

return Text
