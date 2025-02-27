local fs = require("assistant.core.filesystem").new()
local utils = require("assistant.utils")
local luv = vim.uv or vim.loop

local M = {}

local function is_port_in_use(host, port, callback)
  local check = luv.new_tcp()

  if not check then
    callback(false)
    return
  end

  check:connect(host, port, function(err)
    if err then
      check:close()
      callback(false)
    else
      check:write("shutdown", function()
        check:close()
      end)
      callback(true)
    end
  end)
end

local function wait_for_unbind(host, port, attempt, max_attempts, callback)
  if attempt > max_attempts then
    utils.notify_err("Existing server did not unbind in time")
    return
  end

  is_port_in_use(host, port, function(in_use)
    if not in_use then
      callback()
    else
      local delay = math.min(1000 * 2 ^ (attempt - 1), 10000)
      vim.defer_fn(function()
        wait_for_unbind(host, port, attempt + 1, max_attempts, callback)
      end, delay)
    end
  end)
end

function M.stop(callback)
  if M.client then
    M.client:close()
    M.client = nil
  end

  if M.server then
    M.server:close(function()
      M.server = nil
      -- utils.notify_info("TCP server stopped by other neovim instance")

      if callback then
        callback()
      end
    end)
  else
    utils.notify_warn("No running TCP server to stop")

    if callback then
      callback()
    end
  end
end

function M.start()
  if M.server then
    utils.notify_warn("Server is already running")
    return
  end

  M.server = luv.new_tcp()
  if not M.server then
    utils.notify_err("Failed to create server")
    return
  end

  local success, err = pcall(function()
    M.server:bind("127.0.0.1", 10043)
  end)

  if not success then
    utils.notify_err("Server bind error: " .. tostring(err))
    return
  end

  M.server:listen(128, function(s_err)
    if s_err then
      utils.notify_err("Server error: " .. s_err)
      return
    end

    M.client = luv.new_tcp()

    if not M.client then
      utils.notify_err("Failed to create client")
      return
    end

    M.server:accept(M.client)
    M.client:read_start(function(c_err, chunk)
      if c_err then
        utils.notify_err("Client read error: " .. c_err)
        M.client:close()
        return
      end

      if chunk then
        if chunk == "shutdown" then
          M.stop()
        else
          vim.schedule(function()
            fs:save(chunk)
          end)
        end
      end
    end)
  end)

  -- utils.notify_info("TCP server started on 127.0.0.1:10043")
end

function M.init()
  is_port_in_use("127.0.0.1", 10043, function(in_use)
    if in_use then
      -- utils.notify_info("Stopping existing server before initializing")
      local stop_signal = luv.new_tcp()

      if not stop_signal then
        return
      end

      stop_signal:connect("127.0.0.1", 10043, function(err)
        if not err then
          stop_signal:write("shutdown", function()
            stop_signal:close()
            wait_for_unbind("127.0.0.1", 10043, 1, 5, M.start)
          end)
        else
          M.start()
        end
      end)
    else
      M.start()
    end
  end)
end

return M
