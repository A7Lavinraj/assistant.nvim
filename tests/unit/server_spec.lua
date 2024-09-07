---@diagnostic disable: undefined-global

describe("Assistant Server", function()
  it("can listen", function()
    local cmd = ""

    if
      vim.loop.os_uname().sysname == "Linux"
      or vim.loop.os_uname().sysname == "Darwin"
    then
      cmd = "netstat -atpn | grep :" .. 10043
    elseif vim.loop.os_uname().sysname == "Windows" then
      cmd = "netstat -ano | findstr :" .. 10043
    end

    assert(os.execute(cmd))
  end)
end)
