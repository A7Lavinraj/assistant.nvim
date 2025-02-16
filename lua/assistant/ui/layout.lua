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

---@class Ast.Layout.Opts
---@field width number
---@field height number
---@field pane_config table<string, Ast.Layout.PaneConfig>

---@class Ast.Layout
---@field width number
---@field height number
---@field pane_config { root: Ast.Layout.PaneConfig, [string]: Ast.Layout.PaneConfig }
---@field pane_opts table<string, vim.api.keyset.win_config>
---@field augroup integer
---@field is_open boolean
local AstLayout = {}

---@param init_opts Ast.Layout.Opts
function AstLayout.new(init_opts)
  local self = setmetatable({}, { __index = AstLayout })

  self.width = init_opts.width
  self.height = init_opts.height
  self.pane_config = init_opts.pane_config
  self.augroup = api.nvim_create_augroup("AstLayout", { clear = true })
  self:_init()

  return self
end

function AstLayout:_init()
  self.pane_opts = {}

  for name, config in pairs(self.pane_config) do
    if not self.pane_opts[name] then
      self:_resolve_config(name, config)
    end
  end

  api.nvim_create_autocmd("VimResized", {
    group = self.augroup,
    callback = function()
      self:_resize()
    end,
  })

  api.nvim_create_autocmd("WinClosed", {
    group = self.augroup,
    callback = function(event)
      for _, config in pairs(self.pane_config) do
        if config.win == tonumber(event.match) then
          self:hide()
          return
        end
      end
    end,
  })
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
    style = "minimal",
    border = "single",
    relative = "editor",
    title = self.pane_config[name].title,
    title_pos = self.pane_config[name].title_pos,
  }
  if name == "root" then
    self.pane_opts[name].row = math.floor((1 - self.height) * vh * 0.5)
    self.pane_opts[name].col = math.floor((1 - self.width) * vw * 0.5)
  end

  self.pane_opts[name].width = math.floor(vw * self.width * (config.width or 0))
  self.pane_opts[name].height = math.floor(vh * self.height * (config.height or 0))

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

function AstLayout:_resize()
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

function AstLayout:show()
  if self.is_open then
    return
  end

  for name, opts in pairs(self.pane_opts) do
    self.pane_config[name].buf = api.nvim_create_buf(false, true)
    self.pane_config[name].win =
      api.nvim_open_win(self.pane_config[name].buf, self.pane_config[name].enter or false, opts)
  end

  self.is_open = true
end

function AstLayout:hide()
  if not self.is_open then
    return
  end

  for name, _ in pairs(self.pane_opts) do
    if utils.is_win(self.pane_config[name].win) then
      api.nvim_win_close(self.pane_config[name].win, true)
      self.pane_config[name].win = nil
    end

    if utils.is_buf(self.pane_config[name].buf) then
      vim.api.nvim_buf_delete(self.pane_config[name].buf, { force = true })
      self.pane_config[name].buf = nil
    end
  end

  self.is_open = false
end

return AstLayout
