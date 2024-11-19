local Float = require("assistant.ui.float")
local emit = require("assistant.emitter")

local M = {}
M.is_open = false
M.current_window = 1
local WIN_HIGHLIGHTS = {
  "NormalFloat:AssistantFloat",
  "FloatBorder:AssistantFloatBorder",
  "FloatTitle:AssistantFloatTitle",
}
---@type vim.api.keyset.win_config
local SHARED_WIN_CONFIG = {
  relative = "editor",
  border = "rounded",
  style = "minimal",
  title_pos = "center",
}

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
    conf.title = " [1] HOME "
    conf.height = math.ceil(wh * 0.8)
    conf.width = math.ceil(ww * 0.5)
    conf.row = rr - 1
    conf.col = cr - 1
  end

  if i == 1 and j == 2 then
    conf.title = " [2] INPUT "
    conf.height = math.ceil(wh * 0.5)
    conf.width = ww - math.ceil(ww * 0.5)
    conf.row = rr - 1
    conf.col = cr + math.ceil(ww * 0.5) + 1
  end

  if i == 2 and j == 1 then
    conf.title = " [3] LOGS "
    conf.height = wh - math.ceil(wh * 0.8)
    conf.width = math.ceil(ww * 0.5)
    conf.row = rr + math.ceil(wh * 0.8) + 1
    conf.col = cr - 1
  end

  if i == 2 and j == 2 then
    conf.title = " [4] OUTPUT "
    conf.height = wh - math.ceil(wh * 0.5)
    conf.width = ww - math.ceil(ww * 0.5)
    conf.row = rr + math.ceil(wh * 0.5) + 1
    conf.col = cr + math.ceil(ww * 0.5) + 1
  end

  return vim.tbl_deep_extend("force", SHARED_WIN_CONFIG, conf)
end

---@alias AssistantView AssistantFloat[][]
---@type AssistantView
M.view = { {}, {} }

for i = 1, 2 do
  for j = 1, 2 do
    table.insert(M.view[i], Float.new())
    M.view[i][j]:init({
      enter = i == 1 and j == 1,
      wopts = {
        winhighlight = table.concat(WIN_HIGHLIGHTS, ","),
      },
      conf = M.get_conf(i, j),
    })
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

  for i = 1, 2 do
    for j = 1, 2 do
      if M.view[i][j]:is_win() then
        M.view[i][j]:create()
      end
    end
  end
end

function M.open()
  for i = 1, 2 do
    for j = 1, 2 do
      if not M.view[i][j]:is_win() then
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

function M.move()
  M.current_window = M.current_window % 4 + 1

  if M.current_window == 1 then
    vim.fn.win_gotoid(M.view[1][1].win)
  end

  if M.current_window == 2 then
    vim.fn.win_gotoid(M.view[1][2].win)
  end

  if M.current_window == 3 then
    vim.fn.win_gotoid(M.view[2][1].win)
  end

  if M.current_window == 4 then
    vim.fn.win_gotoid(M.view[2][2].win)
  end
end

return M
