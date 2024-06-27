local emitter = require("assistant.emitter")
local store = require("assistant.store")

local M = {}

M.is_open = false

function M.is_buf()
  if not M.buf then
    return false
  end

  return vim.api.nvim_buf_is_valid(M.buf)
end

function M.is_win()
  if not M.win then
    return false
  end

  return vim.api.nvim_win_is_valid(M.win)
end

function M.open(number, field)
  if M.is_open or M.is_buf() or M.is_win() then
    return
  end

  M.tc_number = number
  M.field = field
  M.is_open = true
  M.buf = vim.api.nvim_create_buf(false, true)
  M.win = vim.api.nvim_open_win(M.buf, true, {
    relative = "editor",
    height = 20,
    width = 50,
    row = math.floor(vim.o.lines / 2) - 10,
    col = math.floor(vim.o.columns / 2) - 25,
    style = "minimal",
    border = "rounded",
    -- title = "prompt",
    -- title_pos = "center",
  })

  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, vim.split(store.PROBLEM_DATA["tests"][M.tc_number][M.field], "\n"))

  vim.keymap.set("n", "q", M.close, { buffer = M.buf })
end

function M.close()
  if M.is_open then
    store.PROBLEM_DATA["tests"][M.tc_number][M.field] =
      table.concat(vim.api.nvim_buf_get_lines(M.buf, 0, -1, false), "\n")

    if M.is_win() then
      vim.api.nvim_win_close(M.win, true)
      M.win = nil
    end

    if M.is_buf() then
      vim.api.nvim_buf_delete(M.buf, { force = true })
      M.buf = nil
    end

    M.is_open = false
    emitter.emit("AssistantRender")
  end
end

function M.toggle()
  if M.is_open then
    M.close()
  else
    M.open()
  end
end

return M
