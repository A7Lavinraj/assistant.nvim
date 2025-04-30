---@class Assistant.Window.Options
---@field enter? boolean
---@field width? fun(vw: integer, vh: integer):integer
---@field height? fun(vw: integer, vh: integer):integer
---@field col? fun(vw: integer, vh: integer):integer
---@field row? fun(vw: integer, vh: integer):integer
---@field width_delta? integer
---@field height_delta? integer
---@field col_delta? integer
---@field row_delta? integer
---@field border? string
---@field title? string|table
---@field title_pos? string
---@field zindex? integer
---@field wo? table
---@field bo? table
---@field ref? Assistant.Window
---@field keys? table<"i"|"n"|"v", table<string, Assistant.Action|function>>

---@class Assistant.Window : Assistant.Window.Options
---@field bufnr? integer
---@field winid? integer
local Window = {}

---@param options Assistant.Window.Options
---@return Assistant.Window
function Window.new(options)
  return setmetatable({}, { __index = Window }):init(options)
end

---@param options? Assistant.Window.Options
---@return Assistant.Window
function Window:init(options)
  for k, v in pairs(options or {}) do
    self[k] = v
  end

  return self
end

return Window
