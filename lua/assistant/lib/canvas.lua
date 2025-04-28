---@class Assistant.Canvas.Options
---@field fn fun(bufnr: integer, ...)
---@field gn? fun(bufnr: integer, winid: integer): integer?

---@class Assistant.Canvas : Assistant.Canvas.Options
local Canvas = {}

---@param options Assistant.Canvas.Options
function Canvas.new(options)
  return setmetatable({}, {
    __index = Canvas,
  }):init(options)
end

---@param options Assistant.Canvas.Options
---@return Assistant.Canvas
function Canvas:init(options)
  assert(options.fn, 'set function required')

  for k, v in pairs(options or {}) do
    self[k] = v
  end

  return self
end

---@param bufnr integer
function Canvas:set(bufnr, ...)
  self.fn(bufnr, ...)
end

---@param bufnr integer
---@param winid integer
---@return integer?
function Canvas:get(bufnr, winid)
  return self.gn and self.gn(bufnr, winid) or nil
end

return Canvas
