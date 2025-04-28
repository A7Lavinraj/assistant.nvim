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

---@return vim.api.keyset.win_config
function Window:get_win_config()
  assert(self.width, 'options.width is required')
  assert(self.height, 'options.height is required')
  ---@type vim.api.keyset.win_config
  local options = {}
  options.style = 'minimal'
  options.width = self.width(get_view_size()) + (self.width_delta or 0)
  options.height = self.height(get_view_size()) + (self.height_delta or 0)
  options.col = self.col(get_view_size()) + (self.col_delta or 0)
  options.row = self.row(get_view_size()) + (self.row_delta or 0)
  options.border = require('assistant.config').values.ui.border
  options.title = self.title
  options.title_pos = self.title_pos
  options.relative = 'editor'
  options.zindex = self.zindex or 1
  return options
end

---@param config vim.api.keyset.win_config
function Window:set_win_config(config)
  if self.winid and vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_win_set_config(
      self.winid,
      vim.tbl_deep_extend('force', vim.api.nvim_win_get_config(self.winid), config)
    )
  end
end

---@param options table
function Window:set_win_options(options)
  self.wo = self.wo or {}

  for k, v in pairs(options or {}) do
    vim.wo[self.winid][k] = v
    self.wo[k] = v
  end
end

---@param options table
function Window:set_buf_options(options)
  self.bo = self.bo or {}

  for k, v in pairs(options or {}) do
    vim.bo[self.bufnr][k] = v
    self.bo[k] = v
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

---@param event string|string[]
---@param options vim.api.keyset.create_autocmd
function Window:attach_autocmd(event, options)
  options.group = require('assistant.config').augroup
  options.buffer = self.bufnr
  vim.api.nvim_create_autocmd(event, options)
end

---@class Asssistant.Window.Keyamp.Config
---@field mode string|string[]
---@field lhs string
---@field rhs string|function|Assistant.Action
---@field options? vim.keymap.set.Opts

---@param config Asssistant.Window.Keyamp.Config
function Window:set_keymap(config)
  config = config or {}
  local mode = config.mode or 'n'
  local lhs = config.lhs
  local rhs = config.rhs
  local options = vim.tbl_deep_extend('force', config.options or {}, {
    buffer = self.bufnr,
    silent = true,
    noremap = true,
    desc = (type(rhs) == 'table' and rhs:get_name() or nil),
  })

  if type(rhs) == 'string' then
    vim.keymap.set(mode, lhs, rhs, options)
  elseif type(rhs) == 'function' then
    vim.keymap.set(mode, lhs, rhs, options)
  else
    vim.keymap.set(mode, lhs, function()
      rhs()
    end, options)
  end
end

function Window:open()
  if self.winid and vim.api.nvim_win_is_valid(self.winid) then
    return
  end

  self.bufnr = vim.api.nvim_create_buf(false, true)
  self.winid = vim.api.nvim_open_win(self.bufnr, self.enter, self:get_win_config())

  self:set_win_options {
    winhighlight = table.concat({
      'Normal:AssistantNormal',
      'FloatBorder:AssistantBorder',
      'FloatTitle:AssistantTitle',
    }, ','),
  }
end

function Window:close()
  if not (self.winid and vim.api.nvim_win_is_valid(self.winid)) then
    return
  end

  if self.winid and vim.api.nvim_win_is_valid(self.winid) then
    vim.api.nvim_win_close(self.winid, true)
    self.winid = nil
  end

  if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
    self.bufnr = nil
  end
end

return Window
