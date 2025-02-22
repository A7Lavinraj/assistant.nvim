---@alias Ast.Text.Line { str: string, hl: string }

---@class Ast.Text
---@field pd integer
---@field lines Ast.Text.Line[][]
local AstText = {}

---@return Ast.Text
function AstText.new()
  local self = setmetatable({}, { __index = AstText })
  self:_init()
  return self
end

function AstText:_init()
  self.pd = 2
  self.lines = { {} }
end

---@param count integer?
function AstText:nl(count)
  for _ = 1, (count or 1) do
    table.insert(self.lines, {})
  end

  return self
end

---@param str string
---@param hl string
function AstText:append(str, hl)
  table.insert(self.lines[#self.lines], { str = str, hl = hl })
  return self
end

return AstText
