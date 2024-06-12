---@class AssistantRenderer
local Renderer = {}

function Renderer.new()
  local self = setmetatable({}, { __index = Renderer })
  self.padding = 2

  return self
end

local function is_buf(buf)
  if buf == nil then
    return false
  end

  return vim.api.nvim_buf_is_valid(buf)
end

---@param buf number
---@param text AssistantText
function Renderer:text(buf, text)
  vim.cmd("doautocmd User AssistantRenderStart")
  local lines = {}

  for _, row in pairs(text.lines) do
    local line = string.rep(" ", self.padding)

    for i, col in pairs(row) do
      line = line .. col.str .. string.rep(" ", i == #row and 0 or 1)
    end

    table.insert(lines, line)
  end

  if is_buf(buf) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  for cnt, row in pairs(text.lines) do
    local offset = self.padding

    for _, col in pairs(row) do
      if is_buf(buf) then
        vim.api.nvim_buf_add_highlight(buf, -1, col.hl, cnt - 1, offset, offset + #col.str)
      end

      offset = offset + #col.str + 1
    end
  end

  vim.cmd("doautocmd User AssistantRenderEnd")
end

return Renderer
