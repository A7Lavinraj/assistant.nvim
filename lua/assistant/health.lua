local health = vim.health or require 'health'
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn

local M = {}

function M.check()
  start 'Checking for available source config'

  local commands = require('assistant.config').values.commands

  for source, config in pairs(commands) do
    local cmd = config.compile and config.compile.main or config.execute.main
    if cmd and vim.fn.executable(cmd) == 1 then
      ok(('Found \'%s\' executable for source \'%s\''):format(cmd, source))
    else
      warn(('Missing executable for source \'%s\''):format(source), {
        ('Expected command: \'%s\''):format(cmd or 'nil'),
        'This source won\'t work unless the command is installed.',
      })
    end
  end
end

return M
