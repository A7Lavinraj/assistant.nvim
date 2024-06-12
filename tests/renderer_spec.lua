---@diagnostic disable: undefined-field, undefined-global

local renderer = require("assistant.ui.renderer").new()
local text = require("assistant.ui.text").new()

describe("renderer", function()
  it("can write in buffer", function()
    local content = "Assistant.nvim"

    text:append(content, "assistantNote")
    renderer:text(0, text)

    if table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false)) ~= string.rep(" ", renderer.padding) .. content then
      assert(false, "Unable to write in buffer")
    end
  end)
end)
