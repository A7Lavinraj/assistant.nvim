---@alias Ast.Text.Line { str: string, hl: string }

---@class Ast.Text.Opts
---@field pd integer
---@field lines Ast.Text.Line[][]

---@class Ast.Text
---@field pd integer
---@field lines Ast.Text.Line[][]
local AstText = {}

---@return Ast.Text
function AstText.new(init_opts)
  init_opts = init_opts or {}

  local self = setmetatable({}, { __index = AstText })

  self.pd = init_opts.pd or 0
  self.lines = { {} }

  return self
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
