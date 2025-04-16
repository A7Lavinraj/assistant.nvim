local utils = {}

---@param message string
function utils.info(message)
  vim.notify(message, vim.log.levels.INFO, { title = 'Assistant.nvim' })
end

---@param message string
function utils.warn(message)
  vim.notify(message, vim.log.levels.WARN, { title = 'Assistant.nvim' })
end

---@param message string
function utils.error(message)
  vim.notify(message, vim.log.levels.ERROR, { title = 'Assistant.nvim' })
end

---@param str string
function utils.to_snake_case(str)
  return str
    :gsub('(%s)', '_')
    :gsub('(%u%l)', '_%1')
    :gsub('(%l)(%u)', '%1_%2')
    :gsub('^_', '')
    :gsub('^%s*(.-)%s*$', '%1')
    :gsub('%s+', '_')
    :gsub('(%l)(%u)', '%1_%2')
    :gsub('(%l)(%d)', '%1_%2')
    :gsub('(%d)(%l)', '%1_%2')
    :gsub('(%d)(%u)', '%1_%2')
end

---@param str string
---@param n number
---@return table<string>
function utils.slice_first_n_lines(str, n)
  local lines = {}

  for line in str:gmatch '[^\n]*' do
    if line ~= '' then
      table.insert(lines, line)
    end

    if #lines == n then
      break
    end
  end

  return lines
end

return utils
