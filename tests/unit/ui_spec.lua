---@diagnostic disable: undefined-global

local ui = require("assistant.ui")

describe("Assistant UI", function()
  it("can be toggled", function()
    ui:toggle()
    assert(ui:is_buf())

    ui:toggle()
    assert(not ui:is_buf())
  end)
end)
