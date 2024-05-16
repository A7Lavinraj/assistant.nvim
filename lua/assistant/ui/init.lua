require("assistant.ui.colors").load()
local ButtonSet = require("assistant.ui.buttonset")
local Renderer = require("assistant.ui.renderer")
local Runner = require("assistant.runner")
local Text = require("assistant.ui.text")
local Window = require("assistant.ui.window")
local config = require("assistant.config")
local utils = require("assistant.ui.utils")

local window = Window.new()
local renderer = Renderer.new()
local buttonset = ButtonSet.new()
local text = Text.new()
local runner = Runner.new()
local M = {}

function M.open()
  window.state:sync()
  window:create_window()
  window.state.test_data =
    utils.fetch(string.format("%s/.ast/%s", window.state.CWD, window.state.FILENAME_WITHOUT_EXTENSION))

  renderer:init({ padding = 2, bufnr = window.buf })
  buttonset:init({ gap = 2 })
  buttonset
    :add({ text = " 󰟍 Assistant.nvim(H) ", group = "AssistantButtonActive", is_active = true })
    :add({ text = "  Run Test(R) ", group = "AssistantButton", is_active = false })

  local function home_tab()
    window:clear_window(0, -1)
    text:update({})
    buttonset:click(1)
    renderer:buttons(buttonset)

    if window.state.test_data then
      text:newline():append(string.format("Name: %s", window.state.test_data["name"]), "AssistantH1")
      text
        :newline()
        :append(
          string.format(
            "Time limit: %.2f seconds, Memory limit: %s MB",
            window.state.test_data["timeLimit"] / 1000,
            window.state.test_data["memoryLimit"]
          ),
          "AssistantFadeText"
        )
        :newline()

      for _, test in ipairs(window.state.test_data["tests"]) do
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
      text:newline():append(" No sample found", "AssistantError")
    end

    renderer:text(text)
  end

  local function render_tests(tests)
    text:update({})
    text:newline()
    for index, test in ipairs(tests) do
      text
        :append(
          string.format(
            "%s Testcase #%d: %s",
            (test.expand and test.expand == true and test.status ~= "RUNNING") and "" or "",
            index,
            test.status
          ),
          test.group
        )
        :newline()

      if test.expand and test.expand == true and test.status ~= "RUNNING" then
        text:append("INPUT", "AssistantH2"):append("----------", "AssistantH2")

        for _, line in ipairs(vim.split(test.input, "\n")) do
          text:append(line, "AssistantText")
        end

        text:append("EXPECTED", "AssistantH2"):append("----------", "AssistantH2")

        for _, line in ipairs(vim.split(test.output, "\n")) do
          text:append(line, "AssistantText")
        end

        text:append("STDOUT", "AssistantH2"):append("----------", "AssistantH2")

        if test.stdout then
          for _, line in ipairs(vim.split(test.stdout, "\n")) do
            text:append(line, "AssistantText")
          end
        else
          text:append("NIL", "AssistantFadeText"):newline()
        end

        text:append("STDERR", "AssistantH2"):append("----------", "AssistantH2")

        if test.stderr then
          for _, line in ipairs(vim.split(test.stderr, "\n")) do
            text:append(line, "AssistantText")
          end
        else
          text:append("NIL", "AssistantFadeText"):newline()
        end
      end
    end

    vim.schedule(function()
      window:clear_window(2, -1)
      renderer:text(text)
    end)
  end

  local function run_tab()
    window:clear_window(0, -1)
    buttonset:click(2)
    renderer:buttons(buttonset)

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

    if config.default.commands[window.state.FILETYPE] == nil then
      text:update({})
      text
        :newline()
        :append("Command not found for the given filetype", "AssistantError")
        :newline()
        :append("It might be caused by the improper plugin configuration", "AssistantFadeText")

      renderer:text(text)
    else
      if window.state.test_data then
        runner:init({
          tests = window.state.test_data["tests"],
          command = {
            compile = interpolate(config.default.commands[window.state.FILETYPE].compile),
            execute = interpolate(config.default.commands[window.state.FILETYPE].execute),
          },
          time_limit = config.default.time_limit,
          cmp_cb = function(code, stderr)
            vim.schedule(function()
              window:clear_window(2, -1)
              text
                :update({})
                :newline()
                :append(string.format("COMPILATION ERROR (CODE: %d)", code), "AssistantError")
                :newline()

              for _, line in pairs(stderr) do
                text:append(line, "AssistantFadeText")
              end

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

      local cursor_pos = vim.api.nvim_win_get_cursor(window.win)
      render_tests(window.state.test_data["tests"])

      vim.schedule(function()
        vim.api.nvim_win_set_cursor(window.win, cursor_pos)
      end)
    end
  end, { noremap = true, silent = true, desc = "Assistant Run Test", buffer = window.buf })
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
