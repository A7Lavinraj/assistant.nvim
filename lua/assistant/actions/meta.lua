---@class Assistant.Action
---@field _func table<string, { name: string, fn: function }>
---@field _order string[]
local Action = {}

local Action_mt = {}
Action_mt.__index = Action

---@param t Assistant.Action
function Action_mt.__call(t, ...)
  for _, name in ipairs(t._order) do
    t._func[name].fn(...)
  end
end

---@param lhs Assistant.Action
---@param rhs Assistant.Action
---@return Assistant.Action
function Action_mt.__add(lhs, rhs)
  local merged_func = {}
  local merged_order = {}

  for _, name in ipairs(lhs._order) do
    merged_func[name] = lhs._func[name]
    table.insert(merged_order, name)
  end

  for _, name in ipairs(rhs._order) do
    merged_func[name] = rhs._func[name]
    table.insert(merged_order, name)
  end

  return setmetatable({
    _func = merged_func,
    _order = merged_order,
  }, Action_mt)
end

---@param name string
---@param fn function
---@return Assistant.Action
function Action.new(name, fn)
  return setmetatable({
    _func = {
      [name] = {
        name = name,
        fn = fn,
      },
    },
    _order = { name },
  }, Action_mt)
end

---@param mod table<string, function>
---@return table<string, Assistant.Action>
function Action.transform_mod(mod)
  local out = {}
  for name, fn in pairs(mod) do
    out[name] = Action.new(name, fn)
  end
  return out
end

---@return string
function Action:get_name()
  return table.concat(self._order, ' + ')
end

return Action
