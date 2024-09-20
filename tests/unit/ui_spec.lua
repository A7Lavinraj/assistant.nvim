---@diagnostic disable: undefined-global

local ui = require("assistant.ui")

describe("Assistant UI", function()
  it("can be toggled", function()
    ui.toggle()
    assert(ui.main:is_buf())
    assert(ui.prev:is_buf())

    ui.toggle()
    assert(not ui.main:is_buf())
    assert(not ui.prev:is_buf())
  end)
end)
