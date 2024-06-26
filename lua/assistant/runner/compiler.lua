local config = require("assistant.config")
local emitter = require("assistant.emitter")
local store = require("assistant.store")
local utils = require("assistant.utils")

local M = {}

function M.compile(callback)
  if not store.PROBLEM_DATA then
    return
  end

  print(vim.inspect(store.FILETYPE))

  local command = utils.interpolate(
    store.FILENAME_WITH_EXTENSION,
    store.FILENAME_WITHOUT_EXTENSION,
    config.commands[store.FILETYPE].compile
  )

  for i = 1, #store.PROBLEM_DATA["tests"] do
    store.PROBLEM_DATA["tests"][i].status = "COMPILING"
    store.PROBLEM_DATA["tests"][i].group = "AssistantCompiling"
  end

  store.COMPILE_STATUS = { code = nil, error = nil }

  emitter.emit("AssistantRender")

  if not command then
    emitter.emit("AssistantRender")
  else
    vim.fn.jobstart(vim.tbl_flatten({ command.main, command.args }), {
      stderr_buffered = true,
      on_stderr = function(_, data)
        store.COMPILE_STATUS.error = data
      end,
      on_exit = function(_, code)
        store.COMPILE_STATUS.code = code

        if store.COMPILE_STATUS.code == 0 then
          callback()
        else
          emitter.emit("AssistantRender")
        end
      end,
    })
  end
end

return M
