local AstLayout = require("assistant.ui.layout")
local utils = require("assistant.utils")
local opt = require("assistant.config").opts

local M = {}

function M.create()
  local self = AstLayout.new({
    width = opt.ui.width,
    height = opt.ui.height,
    backdrop = opt.ui.backdrop,
    border = opt.ui.border,
    zindex = 1,
    pane_config = {
      Tasks = {
        style = "minimal",
        relative = "editor",
        width = 0.4,
        height = 1,
        dheight = -3,
        title = " Tasks " .. opt.ui.tasks.title_icon,
        enter = true,
      },
      Actions = {
        style = "minimal",
        relative = "editor",
        dheight = 1,
        width = 0.4,
        bottom = "Tasks",
        border = opt.ui.actions.border,
        title = " Actions " .. opt.ui.tasks.title_icon,
      },
      Logs = {
        style = "minimal",
        relative = "editor",
        width = 0.6,
        height = 1,
        right = "Tasks",
        border = opt.ui.logs.border,
        title = " Logs " .. opt.ui.tasks.title_icon,
      },
    },
  })

  self:bind_cmd("WinClosed", function(event)
    for _, config in pairs(self.pane_config) do
      if config.win == tonumber(event.match) then
        return self:close()
      end
    end
  end)

  self:bind_cmd("VimResized", function()
    self:resize()
  end)

  for name, config in pairs(self.pane_config) do
    if name == "Backdrop" then
      goto continue
    end

    self:bind_key("q", function()
      self:close()
    end, { buffer = config.buf })

    ::continue::
  end

  return self
end

function M:mount()
  local winhls = { "NormalFloat", "FloatBorder", "FloatTitle" }

  for name, config in pairs(self.view.pane_config) do
    local winhl = ""

    for index, hl in ipairs(winhls) do
      if index ~= 1 then
        winhl = winhl .. ","
      end

      winhl = winhl .. string.format("%s:Ast%s%s", hl, name, hl)
    end

    utils.wo(config.win, "winhighlight", winhl)

    if self.backdrop and name == "Backdrop" then
      utils.wo(config.win, "winblend", self.backdrop)
    end
  end
end

function M.toggle()
  M.view = M.view or M.create()

  if M.view.is_open then
    M.view:close()
  else
    M.view:open()

    for name, _ in pairs(M.view.pane_config) do
      if not utils.is_win(M.view.pane_config[name].win) then
        return
      end
    end

    M:mount()
  end
end

return M
