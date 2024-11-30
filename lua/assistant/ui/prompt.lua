local Float = require("assistant.ui.float")
local maps = require("assistant.mappings")
local store = require("assistant.store")
local utils = require("assistant.utils")
local M = {}

M.float = Float.new()

---@return vim.api.keyset.win_config
function M.conf()
  local vh, vw = utils.get_view_port()

  return {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    height = math.floor(vh * 0.5),
    width = math.floor(vw * 0.5),
    row = math.floor(vh * 0.5) - math.floor(vh * 0.25),
    col = math.floor(vw * 0.5) - math.floor(vw * 0.25),
  }
end

function M.hide_and_save_input()
  local current_line = vim.api.nvim_get_current_line()
  local index = tonumber(current_line:match("testcase #(%d+)%s+"))

  if not index then
    return
  end

  M.show({
    pre = function()
      if store.PROBLEM_DATA["tests"][index].input then
        vim.api.nvim_buf_set_lines(M.float.buf, 0, -1, false, vim.split(store.PROBLEM_DATA["tests"][index].input, "\n"))
      end
    end,
    post = function()
      local lines = vim.api.nvim_buf_get_lines(M.float.buf, 0, -1, false)
      M.hide()
      store.PROBLEM_DATA["tests"][index].input = table.concat(lines, "\n")
    end,
  })
end

function M.hide_and_save_expect()
  local current_line = vim.api.nvim_get_current_line()
  local index = tonumber(current_line:match("testcase #(%d+)%s+"))

  if not index then
    return
  end

  M.show({
    pre = function()
      if store.PROBLEM_DATA["tests"][index].output then
        vim.api.nvim_buf_set_lines(
          M.float.buf,
          0,
          -1,
          false,
          vim.split(store.PROBLEM_DATA["tests"][index].output, "\n")
        )
      end
    end,
    post = function()
      local lines = vim.api.nvim_buf_get_lines(M.float.buf, 0, -1, false)
      M.hide()
      store.PROBLEM_DATA["tests"][index].output = table.concat(lines, "\n")
    end,
  })
end

function M.hide()
  M.float:remove()
end

---@param opts {pre:function,post:function}
function M.show(opts)
  M.float.conf = M.conf()
  M.float.enter = true
  M.float:create()
  opts.pre()
  maps.set("n", "<m-cr>", opts.post, M.float.buf)
end

function M.resize()
  if M.float:is_buf() then
    vim.api.nvim_win_set_config(M.float.win, M.conf())
  end
end

return M
