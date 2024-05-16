---@diagnostic disable: undefined-field, undefined-global

local window = require("assistant.ui.window").new()

describe("window", function()
  before_each(function() end)

  it("can be open & close", function()
    window:create_window()

    if window.is_open == false then
      assert(false, "window.is_open is a false value instead of true")
    end
    if window.buf == nil then
      assert(false, "window.buf is a nil value")
    end
    if window.win == nil then
      assert(false, "window.win is a nil value")
    end

    window:delete_window()

    if window.is_open == true then
      assert(false, "window.is_open is a true value instead of false")
    end
    if window.buf ~= nil then
      assert(false, "window.buf is a nil value")
    end
    if window.win ~= nil then
      assert(false, "window.win is a nil value")
    end
  end)
end)
