local interface_actions = {}

---@param winid? integer
local function focus_interface(winid)
  if not (winid and vim.api.nvim_win_is_valid(winid)) then
    return
  end
  vim.fn.win_gotoid(winid)
end

function interface_actions.show_dialog()
  require('assistant.interfaces.dialog'):show()
end

function interface_actions.hide_dialog()
  require('assistant.interfaces.dialog'):hide()
end

function interface_actions.show_editor()
  require('assistant.interfaces.editor'):show()
end

function interface_actions.hide_editor()
  require('assistant.interfaces.editor'):hide()
end

function interface_actions.show_picker()
  require('assistant.interfaces.picker'):show()
end

function interface_actions.hide_picker()
  require('assistant.interfaces.picker'):hide()
end

function interface_actions.show_wizard()
  require('assistant.interfaces.wizard'):show()
end

function interface_actions.hide_wizard()
  require('assistant.interfaces.wizard'):hide()
end

function interface_actions.focus_dialog()
  focus_interface(require('assistant.interfaces.dialog').root.winid)
end

function interface_actions.focus_editor()
  focus_interface(require('assistant.interfaces.editor').root.winid)
end

function interface_actions.focus_picker()
  focus_interface(require('assistant.interfaces.picker').root.winid)
end

function interface_actions.focus_wizard()
  focus_interface(require('assistant.interfaces.wizard').root.winid)
end

function interface_actions.hide_current()
  local interface = vim.bo.filetype:match '^assistant_(%w+)$'
  if not interface then
    return
  end
  interface_actions['hide_' .. interface]()
end

return require('assistant.actions.meta').transform_mod(interface_actions)
