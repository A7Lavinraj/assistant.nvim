local fs = require("assistant.core.filesystem").new()

---@class TCPListener
---@field server uv.uv_tcp_t?
---@field client uv.uv_tcp_t?
local TCPListener = {}

function TCPListener.new()
  return setmetatable({ server = nil, client = nil }, { __index = TCPListener })
end

function TCPListener:start()
  self.server = vim.uv.new_tcp()
  self.server:bind("127.0.0.1", 10043)
  self.server:listen(128, function(s_err)
    if s_err then
      return
    end

    self.client = vim.uv.new_tcp()
    self.server:accept(self.client)
    self.client:read_start(function(c_err, chunk)
      if c_err then
        self.client:close()
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

function TCPListener:stop()
  if self.client and not self.client:is_closing() then
    self.client:close()
  end

  if self.server and not self.server:is_closing() then
    self.server:close()
  end
end

return TCPListener
