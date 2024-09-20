---@diagnostic disable: undefined-field, undefined-global

local store = require("assistant.store")
local ui = require("assistant.ui")

describe("Assistant Prompt", function()
  it("can be edit test data", function()
    vim.cmd("edit foo.cpp")
    store.init()

    if not store.PROBLEM_DATA then
      return
    end

    ui.input(1, "input")
    assert(
      table.concat(vim.api.nvim_buf_get_lines(ui.prompt.buf, 0, -1, false), "\n")
        == store.PROBLEM_DATA["tests"][1].input,
      "Store data and prompt data not matched"
    )
    vim.api.nvim_buf_set_lines(ui.prompt.buf, 0, -1, false, { "foobar" })
    ui.prompt:remove()
    assert(store.PROBLEM_DATA["tests"][1].input == "foobar", "Prompt can't edit data")

    ui.input(1, "output")
    assert(
      table.concat(vim.api.nvim_buf_get_lines(ui.prompt.buf, 0, -1, false), "\n")
        == store.PROBLEM_DATA["tests"][1].output,
      "Store data and prompt data not matched"
    )
    vim.api.nvim_buf_set_lines(ui.prompt.buf, 0, -1, false, { "foobar" })
    ui.prompt:remove()
    assert(store.PROBLEM_DATA["tests"][1].input == "foobar", "Prompt can't edit data")
  end)
end)
