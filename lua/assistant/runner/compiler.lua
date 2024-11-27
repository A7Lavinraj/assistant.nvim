local config = require("assistant.config")
local store = require("assistant.store")
local ui = require("assistant.ui")
local utils = require("assistant.utils")

---@param callback function
---@param index number?
return function(callback, index)
  if not store.PROBLEM_DATA then
    return
  end

  local command = utils.interpolate(
    store.FILENAME_WITH_EXTENSION,
    store.FILENAME_WITHOUT_EXTENSION,
    config.commands[store.FILETYPE].compile
  )
  store.COMPILE_STATUS = { code = nil, error = nil }
  ui.render:home()

  if not command then
    callback()
  else
    if index then
      store.PROBLEM_DATA["tests"][index].status = "COMPILING"
      store.PROBLEM_DATA["tests"][index].group = "AssistantCompiling"
    else
      for i = 1, #store.PROBLEM_DATA["tests"] do
        store.PROBLEM_DATA["tests"][i].status = "COMPILING"
        store.PROBLEM_DATA["tests"][i].group = "AssistantCompiling"
      end
    end

    ui.render:home()
    ---@diagnostic disable-next-line: deprecated
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
          ui.render:home()
        end
      end,
    })
  end
end
