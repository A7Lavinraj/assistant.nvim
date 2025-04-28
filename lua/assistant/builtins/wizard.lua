local Previewer = require 'assistant.lib.previewer'
local Wizard = require 'assistant.lib.wizard'
local builtin_previewer_canvas = require 'assistant.builtins.canvas.previewer'
local builtin_wizard_canvas = require 'assistant.builtins.canvas.wizard'
local builtins = {}

function builtins.standard()
  Wizard.new({
    previewer = Previewer.new {
      canvas = builtin_previewer_canvas.standard,
    },
    canvas = builtin_wizard_canvas.standard,
  }):show()
end

return builtins
