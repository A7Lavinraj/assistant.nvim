local utils = require("assistant.utils")

local api = vim.api

---@class Ast.Layout.PaneConfig
---@field name? string
---@field buf? integer
---@field win? integer
---@field width? number
---@field height? number
---@field row? number
---@field col? number
---@field dwidth? integer
---@field dheight? integer
---@field left? string
---@field top? string
---@field right? string
---@field bottom? string
---@field title? string
---@field title_pos? string
---@field enter? boolean
---@field relative? string
---@field style? string
---@field on_attach? function

---@class Ast.Layout.Opts
---@field width number
---@field height number
---@field backdrop? integer
---@field border? string
---@field zindex? integer
---@field pane_config table<string, Ast.Layout.PaneConfig>
---@field on_attach? function
---@field on_mount_start? function
---@field on_mount_end? function

---@class Ast.Layout
---@field width number
---@field height number
---@field backdrop? integer
---@field border? string
---@field zindex? integer
---@field pane_config table<string, Ast.Layout.PaneConfig>
---@field pane_opts table<string, vim.api.keyset.win_config>
---@field augroup integer
---@field is_open boolean
---@field on_attach? function
---@field on_mount_start? function
---@field on_mount_end? function
local AstLayout = {}

---@param init_opts Ast.Layout.Opts
function AstLayout.new(init_opts)
  init_opts = init_opts or {}

  local self = setmetatable({}, { __index = AstLayout })

  self:_init(init_opts)

  return self
end

function AstLayout:_init(init_opts)
  self.width = init_opts.width
  self.height = init_opts.height
  self.backdrop = init_opts.backdrop
  self.border = init_opts.border
  self.zindex = init_opts.zindex
  self.pane_config = init_opts.pane_config
  self.on_attach = init_opts.on_attach
  self.on_mount_start = init_opts.on_mount_start
  self.on_mount_end = init_opts.on_mount_end
  self.augroup = api.nvim_create_augroup("AstLayout", { clear = true })

  self.pane_opts = {}

  if self.backdrop and self.backdrop < 100 then
    self.pane_config.Backdrop = {}
  end

  for name, config in pairs(self.pane_config) do
    if not self.pane_opts[name] then
      self:_resolve_config(name, config)
    end
  end

  if self.on_attach then
    self:on_attach()
  end
end

function AstLayout:bind_key(lhs, rhs, opts, mode)
  vim.keymap.set(mode or "n", lhs, rhs, opts)
end

function AstLayout:bind_cmd(events, fn, opts)
  opts = opts or {}
  opts.group = self.augroup
  opts.callback = fn

  api.nvim_create_autocmd(events, opts)
end

---@param name string
---@param root Ast.Layout.PaneConfig
function AstLayout:_resolve_config(name, root)
  if root.left then
    self:_resolve_config(root.left, self.pane_config[root.left])
  end

  if root.top then
    self:_resolve_config(root.top, self.pane_config[root.top])
  end

  if root.right then
    self:_resolve_config(root.right, self.pane_config[root.right])
  end

  if root.bottom then
    self:_resolve_config(root.bottom, self.pane_config[root.bottom])
  end

  self:_update(name, root)
end

---@param name string
---@param config Ast.Layout.PaneConfig
function AstLayout:_update(name, config)
  local vh, vw = utils.get_view_port()

  self.pane_opts[name] = {
    style = self.pane_config[name].style,
    relative = self.pane_config[name].relative,
    border = self.border,
    title = self.pane_config[name].title,
    title_pos = self.pane_config[name].title_pos,
    zindex = self.backdrop and (self.zindex + 1) or self.zindex,
  }

  if self.backdrop and self.backdrop < 100 then
    self.pane_opts.Backdrop = {
      relative = "editor",
      style = "minimal",
      width = vim.o.columns,
      height = vim.o.lines,
      zindex = self.zindex,
      focusable = false,
      row = 0,
      col = 0,
    }
  end

  self.pane_opts[name].width = math.floor(vw * self.width * (config.width or 0))
  self.pane_opts[name].height = math.floor(vh * self.height * (config.height or 0))

  if not (config.left or config.top or config.right or config.bottom) then
    self.pane_opts[name].row = math.floor((1 - self.height) * vh * 0.5)
    self.pane_opts[name].col = math.floor((1 - self.width) * vw * 0.5)
  end

  if self.pane_config[name].dwidth then
    self.pane_opts[name].width = self.pane_opts[name].width + self.pane_config[name].dwidth
  end

  if self.pane_config[name].dheight then
    self.pane_opts[name].height = self.pane_opts[name].height + self.pane_config[name].dheight
  end

  if self.pane_config[name].left then
    self.pane_opts[name].row = self.pane_opts[self.pane_config[name].left].row
    self.pane_opts[name].col = self.pane_opts[self.pane_config[name].left].col - self.pane_opts[name].width - 2
  end

  if self.pane_config[name].top then
    self.pane_opts[name].col = self.pane_opts[self.pane_config[name].top].col
    self.pane_opts[name].row = self.pane_opts[self.pane_config[name].top].row - self.pane_opts[name].height - 2
  end

  if self.pane_config[name].right then
    self.pane_opts[name].row = self.pane_opts[self.pane_config[name].right].row
    self.pane_opts[name].col = self.pane_opts[self.pane_config[name].right].col
      + self.pane_opts[self.pane_config[name].right].width
      + 2
  end

  if self.pane_config[name].bottom then
    self.pane_opts[name].col = self.pane_opts[self.pane_config[name].bottom].col
    self.pane_opts[name].row = self.pane_opts[self.pane_config[name].bottom].row
      + self.pane_opts[self.pane_config[name].bottom].height
      + 2
  end
end

function AstLayout:resize()
  self.pane_opts = {}

  for name, config in pairs(self.pane_config) do
    if not self.pane_opts[name] then
      self:_resolve_config(name, config)
    end
  end

  for name, opts in pairs(self.pane_opts) do
    if utils.is_win(self.pane_config[name].win) then
      api.nvim_win_set_config(self.pane_config[name].win, opts)
    end
  end
end

function AstLayout:open()
  if self.on_mount_start then
    self:on_mount_start()
  end

  if self.is_open then
    return
  end

  for name, opts in pairs(self.pane_opts) do
    self.pane_config[name].buf = api.nvim_create_buf(false, true)
    self.pane_config[name].win =
      api.nvim_open_win(self.pane_config[name].buf, self.pane_config[name].enter or false, opts)
  end

  if self.on_mount_end then
    self:on_mount_end()
  end

  self.is_open = true
end

function AstLayout:close()
  if not self.is_open then
    return
  end

  for name, _ in pairs(self.pane_opts) do
    if utils.is_win(self.pane_config[name].win) then
      api.nvim_win_close(self.pane_config[name].win, true)
      self.pane_config[name].win = nil
    end
  end

  self.is_open = false
end

return AstLayout
