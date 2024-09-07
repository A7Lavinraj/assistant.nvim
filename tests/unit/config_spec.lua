---@diagnostic disable: undefined-global

local config = require("assistant.config")

describe("Assistant Config", function()
  it("can be configured", function()
    local time_limit = math.random(1000, 10000)

    config.load({
      commands = {
        c = {
          extension = "c",
          compile = {
            main = "gcc",
            args = {
              "$FILENAME_WITH_EXTENSION",
              "-o",
              "$FILENAME_WITHOUT_EXTENSION",
            },
          },
          execute = { main = "./$FILENAME_WITHOUT_EXTENSION", args = nil },
        },
      },
      time_limit = time_limit,
    })

    assert(config.commands["c"])
    assert(config.time_limit == time_limit)
  end)
end)
