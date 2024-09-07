---@diagnostic disable: undefined-field, undefined-global

local prompt = require("assistant.ui.prompt")
local store = require("assistant.store")

describe("Assistant Prompt", function()
  it("can be edit test data", function()
    vim.cmd("edit foo.cpp")
    store:init()

    if not store.PROBLEM_DATA then
      return
    end

    prompt:open(1, "input")
    assert(
      table.concat(
        vim.api.nvim_buf_get_lines(prompt.state.buf, 0, -1, false),
        "\n"
      ) == store.PROBLEM_DATA["tests"][1].input,
      "Store data and prompt data not matched"
    )
    vim.api.nvim_buf_set_lines(prompt.state.buf, 0, -1, false, { "foobar" })
    prompt:close()
    assert(
      store.PROBLEM_DATA["tests"][1].input == "foobar",
      "Prompt can't edit data"
    )

    prompt:open(1, "output")
    assert(
      table.concat(
        vim.api.nvim_buf_get_lines(prompt.state.buf, 0, -1, false),
        "\n"
      ) == store.PROBLEM_DATA["tests"][1].output,
      "Store data and prompt data not matched"
    )
    vim.api.nvim_buf_set_lines(prompt.state.buf, 0, -1, false, { "foobar" })
    prompt:close()
    assert(
      store.PROBLEM_DATA["tests"][1].input == "foobar",
      "Prompt can't edit data"
    )
  end)
end)
