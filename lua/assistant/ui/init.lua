local Float = require("assistant.ui.float")
local store = require("assistant.store")
local utils = require("assistant.utils")

local M = {}
M.home = setmetatable({}, { __index = Float })
M.input = setmetatable({}, { __index = Float })
M.output = setmetatable({}, { __index = Float })
M.prompt = setmetatable({}, { __index = Float })
M.popup = setmetatable({}, { __index = Float })
M.view_config = {
  relative = "editor",
  style = "minimal",
  border = "rounded",
  title_pos = "center",
}
M.view_hi = "NormalFloat:AssistantFloat,FloatBorder:AssistantFloatBorder,FloatTitle:AssistantFloatTitle"
M.is_open = false

--TODO: fix overflow ui for very small window
function M.update_layout()
  local vh, vw = utils.get_view_port()
  local wh = math.ceil(vh * 0.7) - 2
  local ww = math.ceil(vw * 0.7) - 2
  local rr = math.ceil(vh * 0.5) - math.ceil(wh * 0.5) - 1
  local cr = math.ceil(vw * 0.5) - math.ceil(ww * 0.5) - 1

  if not store.PROBLEM_DATA then
    store.PROBLEM_DATA = {}
  end

  if not store.PROBLEM_DATA["name"] then
    store.PROBLEM_DATA["name"] = vim.fn.expand("%:t")
  end

  M.home.conf.title = " " .. store.PROBLEM_DATA["name"] .. " "
  M.home.conf.height = wh
  M.home.conf.width = math.ceil(ww * 0.5)
  M.home.conf.row = rr - 1
  M.home.conf.col = cr - 1
  M.home.conf = vim.tbl_extend("force", M.home.conf, M.view_config)

  M.input.conf.title = " INPUT "
  M.input.conf.height = math.ceil(wh * 0.5)
  M.input.conf.width = ww - math.ceil(ww * 0.5)
  M.input.conf.row = rr - 1
  M.input.conf.col = cr + math.ceil(ww * 0.5) + 1
  M.input.conf = vim.tbl_extend("force", M.input.conf, M.view_config)

  M.output.conf.title = " OUTPUT "
  M.output.conf.height = wh - math.ceil(wh * 0.5)
  M.output.conf.width = ww - math.ceil(ww * 0.5)
  M.output.conf.row = rr + math.ceil(wh * 0.5) + 1
  M.output.conf.col = cr + math.ceil(ww * 0.5) + 1
  M.output.conf = vim.tbl_extend("force", M.output.conf, M.view_config)

  if M.home:is_win() then
    vim.api.nvim_win_set_config(M.home.win, M.home.conf)
  end

  if M.input:is_win() then
    vim.api.nvim_win_set_config(M.input.win, M.input.conf)
  end

  if M.output:is_win() then
    vim.api.nvim_win_set_config(M.output.win, M.output.conf)
  end

  if M.prompt:is_win() then
    vim.api.nvim_win_set_config(M.prompt.win, M.prompt.conf)
  end

  if M.popup:is_win() then
    vim.api.nvim_win_set_config(M.popup.win, M.popup.conf)
  end
end

function M.open()
  store.fetch()
  M.update_layout()
  M.home:create()
  M.input:create()
  M.output:create()
  M.is_open = true
  utils.emit("AssistantViewOpen")
end

function M.close()
  M.home:remove()
  M.input:remove()
  M.output:remove()
  M.is_open = false
  utils.emit("AssistantViewClose")
end

function M.toggle()
  if M.is_open then
    M.close()
  else
    M.open()
  end
end

function M.move_left()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.input.buf or buf == M.output.buf then
    vim.fn.win_gotoid(M.home.win)
  end
end

function M.move_right()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.home.buf then
    vim.fn.win_gotoid(M.input.win)
  end
end

function M.move_up()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.output.buf then
    vim.fn.win_gotoid(M.input.win)
  end
end

function M.move_down()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.input.buf then
    vim.fn.win_gotoid(M.output.win)
  end
end

return M
