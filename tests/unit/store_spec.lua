---@diagnostic disable: undefined-field, undefined-global

local store = require("assistant.store")

describe("Assistant Store", function()
  it("can be synchronized", function()
    vim.cmd("edit main.cpp")
    store.init()

    assert(store.TAB == 1)
    assert(store.CWD == vim.fn.expand("%:p:h"))
    assert(store.FILETYPE == vim.bo.filetype)
    assert(store.FILENAME_WITH_EXTENSION == vim.fn.expand("%:t"))
    assert(store.FILENAME_WITHOUT_EXTENSION == vim.fn.expand("%:t:r"))
  end)
end)
