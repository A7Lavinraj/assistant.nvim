---@diagnostic disable: undefined-field, undefined-global

local Text = require("assistant.ui.text")
local renderer = require("assistant.ui.renderer")

local function get_random_string()
  local LENGTH = math.random(1, 100)
  local str = ""

  for _ = 1, LENGTH do
    str = str .. string.char(math.random(65, 122))
  end

  return str
end

describe("Assistant Renderer", function()
  it("can write in buffer", function()
    local text = Text.new()
    local content = get_random_string()
    text:append(content, "AssistantFadeText")
    renderer.render(0, text)

    assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "") == string.rep(" ", text.padding) .. content)
  end)
end)
