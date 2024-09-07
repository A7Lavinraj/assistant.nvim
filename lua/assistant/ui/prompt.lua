local State = require("assistant.ui.state")
local Text = require("assistant.ui.text")
local Window = require("assistant.ui.window")
local emitter = require("assistant.emitter")
local renderer = require("assistant.ui.renderer")
local store = require("assistant.store")

local M = setmetatable({ access = true }, {
  __index = Window.new(State.new({
    relative = "editor",
    height = 0.5,
    width = 0.3,
    style = "minimal",
    border = "rounded",
  })),
})

---@param tc_number number?
---@param field string
function M:open(tc_number, field)
  self.tc_number = tc_number
  self.field = field
  self:create()
  local data = Text.new(0)
  local test =
    vim.split(store.PROBLEM_DATA["tests"][self.tc_number][self.field], "\n")

  if store.PROBLEM_DATA then
    for index, segment in ipairs(test) do
      data:append(segment, "AssistantText")

      if index ~= #test then
        data:nl()
      end
    end

    renderer.render(self.state.buf, self.access, data)
  end

  self:on_key("n", "q", function()
    self:close()
  end)
  self:on_key("n", "<esc>", function()
    self:close()
  end)
end

function M:close()
  store.PROBLEM_DATA["tests"][self.tc_number][self.field] =
    table.concat(vim.api.nvim_buf_get_lines(self.state.buf, 0, -1, false), "\n")
  emitter.emit("AssistantRender")
  self:remove()
end

return M
