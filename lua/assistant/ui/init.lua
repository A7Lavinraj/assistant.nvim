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

vim.api.nvim_create_autocmd("User", {
  group = window.augroup,
  pattern = "AssistantWindowCreate",
  callback = function()
    M.maps()
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = window.augroup,
  pattern = "AssistantTabRender",
  callback = function()
    for i = 1, #buttons do
      buttons[i].isActive = false
    end

    buttons[window.state.tab].isActive = true
    M.show(window.state.tab)
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = window.augroup,
  pattern = "AssistantRenderStart",
  callback = function()
    if window.buf then
      vim.api.nvim_set_option_value("modifiable", true, { buf = window.buf })
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = window.augroup,
  pattern = "AssistantRenderEnd",
  callback = function()
    if window.buf then
      vim.api.nvim_set_option_value("modifiable", false, { buf = window.buf })
    end
  end,
})

function M.maps()
  vim.keymap.set("n", "q", function()
    window:delete_window()
  end, { buffer = window.buf })

  vim.keymap.set("n", "<tab>", function()
    window.state.tab = window.state.tab % #buttons + 1
    vim.cmd("doautocmd User AssistantTabRender")
  end, { buffer = window.buf })

  vim.keymap.set("n", "<enter>", function()
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
  end, { buffer = window.buf })

  vim.keymap.set("n", "r", function()
    local current_line = vim.api.nvim_get_current_line()
    local number = current_line:match("Testcase #(%d+): %a+")

    if number then
      runner:run_unique(tonumber(number))
    end
  end, { buffer = window.buf })

  vim.keymap.set("n", "R", function()
    runner:run_all()
  end, { buffer = window.buf })
end

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
