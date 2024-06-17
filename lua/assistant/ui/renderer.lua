local emitter = require("assistant.emitter")

local M = {}

---@param buf number
---@param text AssistantText
function M.render(buf, text)
  emitter.emit("AssistantRenderStart")

  local lines = {}

  for _, row in pairs(text.lines) do
    local line = string.rep(" ", text.padding)

    for i, col in pairs(row) do
      line = line .. col.str .. string.rep(" ", i == #row and 0 or 1)
    end

    table.insert(lines, line)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for cnt, row in pairs(text.lines) do
    local offset = text.padding

    for _, col in pairs(row) do
      vim.api.nvim_buf_add_highlight(buf, -1, col.hl, cnt - 1, offset, offset + #col.str)

      offset = offset + #col.str + 1
    end
  end

  emitter.emit("AssistantRenderEnd")
end

return M
