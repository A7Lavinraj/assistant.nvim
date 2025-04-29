local diffing_algo = {}

---@param str_a string
---@param str_b string
---@return Assistant.Text.Line[]
function diffing_algo.get_higlighted_text(str_a, str_b)
  local lines_a = vim.split(str_a, '\n')
  local lines_b = vim.split(str_b, '\n')
  local highlighted_lines = {} ---@type Assistant.Text.Line[]

  for i = 1, math.max(#lines_a, #lines_b) do
    if lines_a[i] ~= lines_b[i] then
      table.insert(highlighted_lines, { str = lines_a[i] or '', hl = 'AssistantFailure' })
      table.insert(highlighted_lines, { str = lines_b[i] or '', hl = 'AssistantSuccess' })
    else
      table.insert(highlighted_lines, { str = lines_b[i] or '', hl = 'AssistantParagraph' })
    end

    if i < math.max(#lines_a, #lines_b) then
      table.insert(highlighted_lines, {})
    end
  end

  return highlighted_lines
end

return diffing_algo
