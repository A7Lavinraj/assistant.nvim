local Float = require("assistant.ui.float")

local M = {}
local WIN_HIGHLIGHTS = {
  "NormalFloat:AssistantFloat",
  "FloatBorder:AssistantFloatBorder",
  "FloatTitle:AssistantFloatTitle",
}
---@type vim.api.keyset.win_config
local SHARED_WIN_CONFIG = {
  relative = "editor",
  border = "single",
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

function M.toggle()
  for i = 1, 2 do
    for j = 1, 2 do
      M.view[i][j]:toggle()
    end
  end
end

return M
