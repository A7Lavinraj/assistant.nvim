local fs = require("assistant.core.filesystem").new()

local M = {}
M.client = vim.loop.new_tcp()
M.server = vim.loop.new_tcp()

function M.init()
  M.server = vim.uv.new_tcp()
  M.server:bind("127.0.0.1", 10043)
  M.server:listen(128, function(s_err)
    if s_err then
      return
    end

    M.client = vim.uv.new_tcp()
    M.server:accept(M.client)
    M.client:read_start(function(c_err, chunk)
      if c_err then
        M.client:close()
        return
      end

      if chunk then
        vim.schedule(function()
          fs:save(chunk)
        end)
      end
    end)
  end)
end

return M
