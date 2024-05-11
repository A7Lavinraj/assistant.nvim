require("assistant.ui.colors").load()
local Window = require("assistant.ui.window")
local Renderer = require("assistant.ui.renderer")
local ButtonSet = require("assistant.ui.buttonset")
local Text = require("assistant.ui.text")
local Runner = require("assistant.runner")
local utils = require("assistant.ui.utils")
local config = require("assistant.config").config

local window = Window.new()
local renderer = Renderer.new()
local buttonset = ButtonSet.new()
local text = Text.new()
local runner = Runner.new()
local M = {}

function M.open()
  window.state:sync()
  window:create_window()
  renderer:init({ padding = 2, bufnr = window.buf })
  buttonset:init({ gap = 2 })

  buttonset
      :add({ text = " 󰟍 Assistant.nvim ", group = "AssistantButtonActive", is_active = true })
      :add({ text = "  Run Test ", group = "AssistantButton", is_active = false })

  local function home_tab()
    window:clear_window(0, -1)
    text:update({})
    buttonset:click(1)
    renderer:buttons(buttonset)

    local data = utils.fetch(string.format("%s/.ast/%s", window.state.CWD, window.state.FILENAME_WITHOUT_EXTENSION))

    if data then
      text:newline():append(string.format("Name: %s", data.name), "AssistantH1")
      text:newline()
          :append(
            string.format(
              "Time limit: %.2f seconds, Memory limit: %s MB",
              data.timeLimit / 1000,
              data.memoryLimit
            ),
            "AssistantDesc"
          )
          :newline()

      for _, test in ipairs(data.tests) do
        text:append("INPUT", "AssistantH2"):append("----------", "AssistantH2")

        for _, value in ipairs(vim.split(test.input, "\n")) do
          text:append(value, "AssistantText")
        end

        text:append("EXPECTED", "AssistantH2"):append("----------", "AssistantH2")

        for _, value in ipairs(vim.split(test.output, "\n")) do
          text:append(value, "AssistantText")
        end
      end
    else
      text:newline():append(" No sample found", "AssistantError"):newline():append(
        ".ast directory might be removed or sample for currently open file not fetched yet.",
        "AssistantDesc"
      )
    end

    renderer:text(text)
  end

  local function run_tab()
    window:clear_window(0, -1)
    buttonset:click(2)
    renderer:buttons(buttonset)

    local data = utils.fetch(string.format("%s/.ast/%s", window.state.CWD, window.state.FILENAME_WITHOUT_EXTENSION))
    local function interpolate(command)
      if not command then
        return nil
      end

      local function replace(filename)
        return filename
            :gsub("%$FILENAME_WITH_EXTENSION", window.state.FILENAME_WITH_EXTENSION)
            :gsub("%$FILENAME_WITHOUT_EXTENSION", window.state.FILENAME_WITHOUT_EXTENSION)
      end

      local _command = vim.deepcopy(command)

      if _command.main then
        _command.main = replace(_command.main)
      end

      if _command.args then
        for i = 1, #command.args do
          _command.args[i] = replace(command.args[i])
        end
      end

      return _command
    end

    if data then
      runner:init({
        tests = vim.deepcopy(data.tests),
        command = {
          compile = interpolate(config.commands[window.state.FILETYPE].compile),
          execute = interpolate(config.commands[window.state.FILETYPE].execute),
        },
        time_limit = config.time_limit,
        cmp_cb = function(code, signal)
          vim.schedule(function()
            window:clear_window(2, -1)
            text:update({})
                :newline()
                :append(
                  string.format("COMPILATION ERROR (CODE: %d, SIGNAL: %d)", code, signal),
                  "AssistantError"
                )
                :newline()
                :append("Looks like your code doesn't compile, fix and try again", "AssistantDesc")
            renderer:text(text)
          end)
        end,
        exe_cb = function(tests)
          vim.schedule(function()
            window:clear_window(2, -1)
            text:update({})

            for index, test in ipairs(tests) do
              text:newline():append(string.format(" Testcase #%d: %s", index, test.status), test.group)
            end

            renderer:text(text)
          end)
        end,
      })

      runner:run_all()
    end
  end

  home_tab()

  vim.keymap.set("n", "q", function()
    window:delete_window()
  end, { noremap = true, silent = true, desc = "Assistant Quit", buffer = window.buf })
  vim.keymap.set(
    "n",
    "<s-h>",
    home_tab,
    { noremap = true, silent = true, desc = "Assistant Run Test", buffer = window.buf }
  )
  vim.keymap.set(
    "n",
    "<s-r>",
    run_tab,
    { noremap = true, silent = true, desc = "Assistant Run Test", buffer = window.buf }
  )
end

function M.close()
  window:delete_window()
end

function M.toggle()
  if window.is_open then
    M.close()
  else
    M.open()
  end
end

return M
