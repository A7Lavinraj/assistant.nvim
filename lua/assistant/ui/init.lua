local Renderer = require("assistant.ui.renderer")
local Runner = require("assistant.runner")
local Text = require("assistant.ui.text")
local Window = require("assistant.ui.window")
local config = require("assistant.config")
local transformer = require("assistant.ui.transformer")
local utils = require("assistant.utils")
require("assistant.ui.colors").load()

local window = Window.new()
local runner = Runner.new()
local renderer = Renderer.new()
local buttons = { { title = " 󰟍 Assistant.nvim ", isActive = true }, { title = "  Run Test ", isActive = false } }

local M = {}

function M.on(pattern, fn)
  vim.api.nvim_create_autocmd("User", {
    group = window.augroup,
    pattern = pattern,
    callback = fn,
  })
end

function M.key(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, { buffer = window.buf })
end

function M.set_mappings()
  M.key("q", function()
    window:delete_window()
  end)
  M.key("<tab>", function()
    window.state.tab = window.state.tab % #buttons + 1
    vim.cmd("doautocmd User AssistantTabRender")
  end)
  M.key("<enter>", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      local test = window.state.test_data["tests"][tonumber(number)]

      if not test.expand then
        test.expand = true
      else
        test.expand = false
      end

      vim.cmd("doautocmd User AssistantTabRender")
    end
  end)
  M.key("r", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      runner:run_unique(tonumber(number))
    end
  end)
  M.key("R", function()
    runner:run_all()
  end)
end

M.on("AssistantWindowCreate", M.set_mappings)
M.on("AssistantTabRender", function()
  for i = 1, #buttons do
    buttons[i].isActive = false
  end

  buttons[window.state.tab].isActive = true
  M.show(window.state.tab)
end)
M.on("AssistantRenderStart", function()
  if window.buf then
    vim.api.nvim_set_option_value("modifiable", true, { buf = window.buf })
  end
end)
M.on("AssistantRenderEnd", function()
  if window.buf then
    vim.api.nvim_set_option_value("modifiable", false, { buf = window.buf })
  end
end)

vim.api.nvim_create_autocmd("BufEnter", {
  group = window.augroup,
  pattern = "*.*",
  callback = function(data)
    if vim.fn.fnamemodify(data.match, ":.") ~= window.state.FILENAME_WITH_EXTENSION then
      window.state:init()
    end
  end,
})

function M.show(tab)
  if tab == 1 then
    renderer:text(
      window.buf,
      transformer.merge(transformer.buttons(buttons), transformer.problem(window.state.test_data))
    )
  elseif tab == 2 then
    local text = Text.new()

    if config.default.commands[window.state.FILETYPE] == nil then
      text:nl()
      text:append("Command not found for the given filetype", "AssistantFadeText")
      renderer:text(window.buf, transformer.merge(transformer.buttons(buttons), text))
    else
      if window.state.test_data then
        runner:init({
          tests = window.state.test_data["tests"],
          command = {
            compile = utils.interpolate(
              window.state.FILENAME_WITH_EXTENSION,
              window.state.FILENAME_WITHOUT_EXTENSION,
              config.default.commands[window.state.FILETYPE].compile
            ),
            execute = utils.interpolate(
              window.state.FILENAME_WITH_EXTENSION,
              window.state.FILENAME_WITHOUT_EXTENSION,
              config.default.commands[window.state.FILETYPE].execute
            ),
          },
          time_limit = config.default.time_limit,
          cmp_cb = function(code, stderr)
            vim.schedule(function()
              text:nl()
              text:append(string.format("COMPILATION ERROR (CODE: %d)", code), "AssistantError")
              text:nl(2)

              for _, line in pairs(stderr) do
                text:append(line, "AssistantFadeText")
                text:nl()
              end

              renderer:text(window.buf, transformer.merge(transformer.buttons(buttons), text))
            end)
          end,
        })

        renderer:text(
          window.buf,
          transformer.merge(transformer.buttons(buttons), transformer.testcases(window.state.test_data["tests"]))
        )
      end
    end
  end
end

function M.toggle()
  if window.is_open then
    window:delete_window()
  else
    window:create_window()
  end
end

return M
