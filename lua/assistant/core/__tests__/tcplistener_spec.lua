package.loaded["assistant.config"] = { opts = { core = { port = 10043 } } }

local tcp = require("assistant.core.tcplistener")
local test = require("mini.test")

local T = test.new_set()

T["TCPListener"] = function()
  tcp.start()
  tcp.is_port_in_use("127.0.0.1", 10043, function(first)
    test.expect.equality(first, true)
    tcp.stop()
    tcp.is_port_in_use("127.0.0.1", 10043, function(second)
      test.expect.equality(second, false)
    end)
  end)
end

return T
