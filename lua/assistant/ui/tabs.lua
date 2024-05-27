local config = require("assistant.config")
local text = require("assistant.ui.text").new()

return {
  function(window)
    text:update({})

    if window.state.test_data then
      text:newline():append({
        content = string.format("Name: %s", window.state.test_data["name"]),
        hl = {
          {
            col_start = 0,
            col_end = -1,
            group = "AssistantH1",
          },
        },
      })
      text
        :newline()
        :append({
          content = string.format(
            "Time limit: %.2f seconds, Memory limit: %s MB",
            window.state.test_data["timeLimit"] / 1000,
            window.state.test_data["memoryLimit"]
          ),
          hl = {
            {
              col_start = 0,
              col_end = -1,
              group = "AssistantFadeText",
            },
          },
        })
        :newline()

      for _, test in ipairs(window.state.test_data["tests"]) do
        text
          :append({
            content = " INPUT ",
            hl = {
              {
                col_start = 2,
                col_end = -1,
                group = "AssistantNote",
              },
            },
          })
          :newline()

        for _, value in ipairs(vim.split(test.input, "\n")) do
          text:append({
            content = value,
            hl = {
              {
                col_start = 0,
                col_end = -1,
                group = "AssistantText",
              },
            },
          })
        end

        text
          :append({
            content = " EXPECTED ",
            hl = {
              {
                col_start = 2,
                col_end = -1,
                group = "AssistantNote",
              },
            },
          })
          :newline()

        for _, value in ipairs(vim.split(test.output, "\n")) do
          text:append({
            content = value,
            hl = {
              {
                col_start = 0,
                col_end = -1,
                group = "AssistantText",
              },
            },
          })
        end
      end
    else
      text:newline():append({
        content = " No sample found",
        hl = {
          {
            col_start = 0,
            col_end = -1,
            group = "AssistantError",
          },
        },
      })
    end

    window.renderer:buttons(window.buttonset)
    window.renderer:text(text)
  end,

  function(window)
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

    window.renderer:buttons(window.buttonset)

    if config.default.commands[window.state.FILETYPE] == nil then
      text:update({})
      text
        :newline()
        :append({
          content = "Command not found for the given filetype",
          hl = {
            {
              col_start = 0,
              col_end = -1,
              group = "AssistantError",
            },
          },
        })
        :newline()
        :append({
          content = "It might be caused by the improper plugin configuration",
          hl = {
            {
              col_start = 0,
              col_end = -1,
              group = "AssistantFadeText",
            },
          },
        })

      window.renderer:text(text)
    else
      if window.state.test_data then
        window.runner:init({
          tests = window.state.test_data["tests"],
          command = {
            compile = interpolate(config.default.commands[window.state.FILETYPE].compile),
            execute = interpolate(config.default.commands[window.state.FILETYPE].execute),
          },
          time_limit = config.default.time_limit,
          cmp_cb = function(code, stderr)
            vim.schedule(function()
              text
                :update({})
                :newline()
                :append({
                  content = string.format("COMPILATION ERROR (CODE: %d)", code),
                  hl = {
                    {
                      col_start = 0,
                      col_end = -1,
                      group = "AssistantError",
                    },
                  },
                })
                :newline()

              for _, line in pairs(stderr) do
                text:append({
                  content = line,
                  hl = {
                    {
                      col_start = 0,
                      col_end = -1,
                      group = "AssistantFadeText",
                    },
                  },
                })
              end

              window.renderer:buttons(window.buttonset)
              window.renderer:text(text)
            end)
          end,
          exe_cb = function(tests)
            vim.schedule(function()
              window.renderer:tests(tests, window)
            end)
          end,
        })

        window.renderer:tests(window.state.test_data["tests"], window)
      end
    end
  end,
}
