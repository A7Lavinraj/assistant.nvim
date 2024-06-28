local emitter = require("assistant.emitter")
local store = require("assistant.store")

---@class AssistantPrompt
local AssistantPrompt = {}

function AssistantPrompt.new()
  return setmetatable({ is_open = false }, { __index = AssistantPrompt })
end

function AssistantPrompt:is_buf()
  if not self.buf then
    return false
  end

  return vim.api.nvim_buf_is_valid(self.buf)
end

function AssistantPrompt:is_win()
  if not self.win then
    return false
  end

  return vim.api.nvim_win_is_valid(self.win)
end

function AssistantPrompt:on_key(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { buffer = self.buf })
end

function AssistantPrompt:open(number, field)
  if self.is_open or self:is_buf() or self:is_win() then
    return
  end

  self.tcnumber = number
  self.field = field
  self.is_open = true
  self.buf = vim.api.nvim_create_buf(false, true)
  self.win = vim.api.nvim_open_win(self.buf, true, {
    relative = "editor",
    height = 20,
    width = 50,
    row = math.floor(vim.o.lines / 2) - 10,
    col = math.floor(vim.o.columns / 2) - 25,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_buf_set_lines(
    self.buf,
    0,
    -1,
    false,
    vim.split(store.PROBLEM_DATA["tests"][self.tcnumber][self.field], "\n")
  )

  self:on_key("n", "q", function()
    self:close()
  end)
  self:on_key("n", "<esc>", function()
    self:close()
  end)
end

function AssistantPrompt:close()
  if self.is_open then
    store.PROBLEM_DATA["tests"][self.tcnumber][self.field] =
      table.concat(vim.api.nvim_buf_get_lines(self.buf, 0, -1, false), "\n")

    if self:is_win() then
      vim.api.nvim_win_close(self.win, true)
      self.win = nil
    end

    if self:is_buf() then
      vim.api.nvim_buf_delete(self.buf, { force = true })
      self.buf = nil
    end

    self.is_open = false
    emitter.emit("AssistantRender")
  end
end

function AssistantPrompt:toggle()
  if self.is_open then
    self:close()
  else
    self:open()
  end
end

return AssistantPrompt.new()
