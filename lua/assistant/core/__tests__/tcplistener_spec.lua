local tcp = require("assistant.core.tcplistener")
local test = require("mini.test")

local T = test.new_set()

T["TCPListener"] = function()
  ---@param cmd string
  ---@return string?
  local function shell(cmd)
    local handle = io.popen(cmd)

    if not handle then
      return nil
    end

    local result = handle:read("*a")
    handle:close()
    return result
  end

  tcp.init()
  vim.uv.sleep(100)
  local result = shell("netstat -an | grep :10043")

  if not result then
    test.expect(false, "[SHELL] `netstat` command problem")
  else
    test.expect.equality(result:match("127%.0%.0%.1:(%d+)"), "10043")
  end
end

return T
