---@param buf number
---@param access boolean
---@param text AssistantText
return function(buf, access, text)
  local lines = {}

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
