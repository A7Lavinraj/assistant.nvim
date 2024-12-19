local tcp = require("assistant.core.tcplistener")

describe("TCPListener", function()
  it("can bind to 10043 {PORT}", function()
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
    vim.loop.sleep(100)
    local result = shell("netstat -an | grep :10043")

    if not result then
      assert(false, "[SHELL] `netstat` command problem")
    else
      assert.are_same(result:match("127%.0%.0%.1:(%d+)"), "10043", "Port 10043 is not bound")
    end
  end)
end)
