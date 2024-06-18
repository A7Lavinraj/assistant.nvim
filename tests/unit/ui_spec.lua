---@diagnostic disable: undefined-global

local ui = require("assistant.ui")

describe("Assistant UI", function()
  it("can be toggled", function()
    ui.toggle_window()
    assert(vim.api.nvim_buf_is_valid(ui.get_state().buf))

    ui.toggle_window()
    assert(not ui.get_state().buf)
  end)
end)
