local Float = require("assistant.ui.float")
local emit = require("assistant.emitter")
local store = require("assistant.store")

local M = {}
M.is_open = false

---@return number, number
function M.get_view_port()
  local vh = vim.o.lines - vim.o.cmdheight
  local vw = vim.o.columns

  if vim.o.laststatus ~= 0 then
    vh = vh - 1
  end

  return vh, vw
end

--TODO: fix overflow ui for very small window
---@param i number
---@param j number
---@return vim.api.keyset.win_config
function M.get_conf(i, j)
  local vh, vw = M.get_view_port()
  local wh = math.ceil(vh * 0.7) - 2
  local ww = math.ceil(vw * 0.7) - 2
  local rr = math.ceil(vh * 0.5) - math.ceil(wh * 0.5) - 1
  local cr = math.ceil(vw * 0.5) - math.ceil(ww * 0.5) - 1
  local conf = {}

  if i == 1 and j == 1 then
    conf.title = " UNTITLED "

    if store.PROBLEM_DATA then
      conf.title = " " .. store.PROBLEM_DATA["name"] .. " "
    end

    conf.height = math.ceil(wh * 0.8)
    conf.width = math.ceil(ww * 0.5)
    conf.row = rr - 1
    conf.col = cr - 1
  end

  if i == 1 and j == 2 then
    conf.title = " INPUT "
    conf.height = math.ceil(wh * 0.5)
    conf.width = ww - math.ceil(ww * 0.5)
    conf.row = rr - 1
    conf.col = cr + math.ceil(ww * 0.5) + 1
  end

  if i == 2 and j == 1 then
    conf.title = " STATS "
    conf.height = wh - math.ceil(wh * 0.8)
    conf.width = math.ceil(ww * 0.5)
    conf.row = rr + math.ceil(wh * 0.8) + 1
    conf.col = cr - 1
  end

  if i == 2 and j == 2 then
    conf.title = " OUTPUT "
    conf.height = wh - math.ceil(wh * 0.5)
    conf.width = ww - math.ceil(ww * 0.5)
    conf.row = rr + math.ceil(wh * 0.5) + 1
    conf.col = cr + math.ceil(ww * 0.5) + 1
  end

  return vim.tbl_deep_extend("force", {
    relative = "editor",
    border = "rounded",
    style = "minimal",
    title_pos = "center",
  }, conf)
end

---@alias AssistantView AssistantFloat[][]
---@type AssistantView
M.view = { {}, {} }

for i = 1, 2 do
  for j = 1, 2 do
    table.insert(M.view[i], Float.new())
    M.view[i][j]:init({ enter = i == 1 and j == 1 })
    M.view[i][j]:wo(
      "winhighlight",
      table.concat({
        "NormalFloat:AssistantFloat",
        "FloatBorder:AssistantFloatBorder",
        "FloatTitle:AssistantFloatTitle",
      }, ",")
    )
    M.view[i][j]:bo("modifiable", false)
  end
end

function M.resize()
  for i = 1, 2 do
    for j = 1, 2 do
      if M.view[i][j]:is_win() then
        local conf = M.get_conf(i, j)
        M.view[i][j]:init({ conf = conf })
        vim.api.nvim_win_set_config(M.view[i][j].win, conf)
      end
    end
  end
end

function M.open()
  store.init()

  for i = 1, 2 do
    for j = 1, 2 do
      if not M.view[i][j]:is_win() then
        M.view[i][j].conf = M.get_conf(i, j)
        M.view[i][j]:create()
      end
    end
  end

  M.is_open = true
  emit("AssistantViewOpen")
end

function M.close()
  for i = 1, 2 do
    for j = 1, 2 do
      if M.view[i][j]:is_win() then
        M.view[i][j]:remove()
      end
    end
  end

  M.is_open = false
  emit("AssistantViewClose")
end

function M.toggle()
  if M.is_open then
    M.close()
  else
    M.open()
  end
end

M.winx = 1
M.winy = 1

function M.move_left()
  if M.winx == 1 then
    return
  end

  M.winx = 1
  vim.fn.win_gotoid(M.view[M.winy][M.winx].win)
end

function M.move_right()
  if M.winx == 2 then
    return
  end

  M.winx = 2
  vim.fn.win_gotoid(M.view[M.winy][M.winx].win)
end

function M.move_up()
  if M.winy == 1 then
    return
  end

  M.winy = 1
  vim.fn.win_gotoid(M.view[M.winy][M.winx].win)
end

function M.move_down()
  if M.winy == 2 then
    return
  end

  M.winy = 2
  vim.fn.win_gotoid(M.view[M.winy][M.winx].win)
end

return M
