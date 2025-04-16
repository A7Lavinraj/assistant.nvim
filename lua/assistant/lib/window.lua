---@class Assistant.Window.Options
---@field name string
---@field enter? boolean
---@field width number
---@field height number
---@field col number
---@field row number
---@field width_delta? integer
---@field height_delta? integer
---@field col_delta? integer
---@field row_delta? integer
---@field border? string
---@field title? string|table
---@field title_pos? string
---@field wo? table
---@field bo? table
---@field ref? Assistant.Window
---@field keys? table<"i"|"n"|"v", table<string, Assistant.Action|function>>

---@class Assistant.Window : Assistant.Window.Options
---@field bufnr? integer
---@field winid? integer
local Window = {}

---@return integer, integer
local function get_view_size()
  local vw = vim.o.columns
  local vh = vim.o.lines - vim.o.cmdheight

  if vim.o.laststatus ~= 0 then
    vh = vh - 1
  end

  return vw, vh
end

---@param options Assistant.Window.Options
---@return Assistant.Window
function Window.new(options)
  return setmetatable({}, { __index = Window }):initialize(options)
end

---@param options Assistant.Window.Options
---@return Assistant.Window
function Window:initialize(options)
  assert(options, 'options are required')
  assert(options.width, 'options.width is required')
  assert(options.height, 'options.height is required')

  for k, v in pairs(options) do
    self[k] = v
  end

  return self
end

---@param parent? Assistant.Window
---@param interface Assistant.Interface
---@return vim.api.keyset.win_config
function Window:get_window_config(parent, interface)
  local vw, vh = get_view_size()
  ---@type vim.api.keyset.win_config
  local options = {}
  options.style = 'minimal'
  options.width = math.floor(self.width * interface.width * vw) + (self.width_delta or 0)
  options.height = math.floor(self.height * interface.height * vh) + (self.height_delta or 0)
  options.col = math.floor(self.col * vw) + (self.col_delta or 0)
  options.row = math.floor(self.row * vh) + (self.row_delta or 0)
  options.border = require('assistant.config').values.ui.border
  options.title = self.title
  options.title_pos = self.title_pos

  if parent then
    options.relative = 'win'
    options.win = parent.winid
    options.col = options.col - 1
    options.row = options.row - 1
  else
    options.relative = 'editor'
  end

  return options
end

---@param config vim.api.keyset.win_config
function Window:set_window_config(config)
  if self.winid and vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_win_set_config(
      self.winid,
      vim.tbl_deep_extend('force', vim.api.nvim_win_get_config(self.winid), config)
    )
  end
end

---@param options table
function Window:set_window_options(options)
  for k, v in pairs(options or {}) do
    vim.wo[self.winid][k] = v
  end
end

---@param options table
function Window:set_buffer_options(options)
  for k, v in pairs(options or {}) do
    vim.bo[self.bufnr][k] = v
  end
end

function Window:set_local_options()
  for k, v in pairs(self.bo or {}) do
    vim.bo[self.bufnr][k] = v
  end

  for k, v in pairs(self.wo or {}) do
    vim.wo[self.winid][k] = v
  end
end

return Window
