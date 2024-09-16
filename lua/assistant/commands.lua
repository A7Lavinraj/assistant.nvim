local emitter = require("assistant.emitter")
local previewer = require("assistant.ui.previewer")
local ui = require("assistant.ui")

local M = {}

function M.load()
  vim.api.nvim_create_user_command("AssistantToggle", function()
    if ui.state.is_open then
      ui:remove()
      previewer:remove()
    else
      ui:create()
      emitter.emit("AssistantOpenWindow")
      emitter.emit("AssistantRender")
    end
  end, {})
end

return M
