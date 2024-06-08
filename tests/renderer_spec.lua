---@diagnostic disable: undefined-field, undefined-global

local renderer = require("assistant.ui.renderer").new()
local text = require("assistant.ui.text").new()

describe("renderer", function()
  it("can be initialized", function()
    renderer:init(0)

    if renderer.buf == nil then
      assert(false, "Unable to initialized")
    end
  end)

  it("can write in buffer", function()
    local content = "Assistant.nvim"

    renderer:init(0)
    text:newline():append({
      content = content,
      hl = {
        {
          col_start = 0,
          col_end = -1,
          group = "AssistantNote",
        },
      },
    })
    renderer:text(text)

    if table.concat(vim.api.nvim_buf_get_lines(0, 2, -1, false)) == content then
      assert(false, "Unable to write in buffer")
    end
  end)
end)
