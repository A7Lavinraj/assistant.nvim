---@diagnostic disable: undefined-field, undefined-global

local window = require("assistant.ui.window").new()
local eq = assert.are.same

describe("assistant", function()
  before_each(function() end)

  it("can be required", function()
    require("assistant")
  end)

  it("window can be open & close", function()
    window:create_window()

    eq(window.is_open, true)
    eq(vim.api.nvim_buf_is_valid(window.buf), true)
    eq(vim.api.nvim_win_is_valid(window.win), true)

    window:delete_window()

    eq(window.is_open, false)
    eq(window.buf, nil)
    eq(window.win, nil)
  end)
end)
