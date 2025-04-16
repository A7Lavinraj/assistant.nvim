---@alias Assistant.Interface.Position "start"|"center"|"end"

---@class Assistant.Interface.Options
---@field width number
---@field height number
---@field col? number
---@field row? number
---@field x_pos? Assistant.Interface.Position
---@field y_pos? Assistant.Interface.Position
---@field root Assistant.Window
---@field be_show? fun(self: Assistant.Interface)
---@field on_show? fun(self: Assistant.Interface)
---@field on_hide? fun(self: Assistant.Interface)

---@class Assistant.Interface : Assistant.Interface.Options
---@field visible boolean
local Interface = {}

---@param options Assistant.Interface.Options
---@return Assistant.Interface
function Interface.new(options)
  return setmetatable({}, { __index = Interface }):initialize(options)
end

---@param options Assistant.Interface.Options
---@return Assistant.Interface
function Interface:initialize(options)
  assert(options, 'options are required')
  assert(options.width, 'options.width is required')
  assert(options.height, 'options.height is required')
  for k, v in pairs(options) do
    self[k] = v
  end
  return self
end

function Interface:show()
  if self.visible then
    return
  end

  if self.be_show then
    self:be_show()
  end

  ---@type Assistant.Window|nil
  local parent = nil
  self:each(function(root)
    root.bufnr = vim.api.nvim_create_buf(false, true)
    root.winid = vim.api.nvim_open_win(root.bufnr, root.enter, root:get_window_config(parent, self))
    root:set_local_options()
    for mode, mappings in pairs(root.keys or {}) do
      for k, v in pairs(mappings) do
        vim.keymap.set(mode, k, function()
          v()
        end, { desc = v:get_name(), silent = true, noremap = true, buffer = root.bufnr })
      end
    end
    parent = root
  end)
  self.visible = true

  if self.on_show then
    self:on_show()
  end
end

function Interface:hide()
  if not self.visible then
    return
  end

  self:each(function(root)
    if root.winid and vim.api.nvim_win_is_valid(root.winid) then
      vim.api.nvim_win_close(root.winid, true)
    end
    if root.bufnr and vim.api.nvim_buf_is_valid(root.bufnr) then
      vim.api.nvim_buf_delete(root.bufnr, { force = true })
    end
  end)
  self.visible = false

  if self.on_hide then
    self:on_hide()
  end
end

---@param fn fun(window: Assistant.Window)
function Interface:each(fn)
  local root = self.root

  while root do
    fn(root)
    root = root.ref
  end
end

function Interface:resize()
  ---@type Assistant.Window|nil
  local parent = nil
  self:each(function(root)
    if root.winid and vim.api.nvim_win_is_valid(root.winid) then
      vim.api.nvim_win_set_config(root.winid, root:get_window_config(parent, self))
      root:set_local_options()
    end
    parent = root
  end)
end

return Interface
