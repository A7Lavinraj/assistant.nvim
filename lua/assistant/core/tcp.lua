local luv = vim.uv or vim.loop
local tcp = {}
local client, server = nil, nil ---@type uv.uv_tcp_t?, uv.uv_tcp_t?

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
      check:write('shutdown', function()
        check:close()
      end)
      callback(true)
    end
  end)
end

local function wait_for_unbind(host, port, attempt, max_attempts, callback)
  local utils = require 'assistant.utils'
  if attempt > max_attempts then
    utils.err 'Existing server did not unbind in time'
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

local function stop_server(callback)
  local utils = require 'assistant.utils'
  if client then
    client:close()
    client = nil
  end

  if server then
    server:close(function()
      server = nil

      if callback then
        callback()
      end
    end)
  else
    utils.warn 'No running TCP server to stop'

    if callback then
      callback()
    end
  end
end

local function start_server()
  local utils = require 'assistant.utils'
  local config = require 'assistant.config'
  local picker = require 'assistant.interfaces.picker'
  local fs = require 'assistant.core.fs'
  if server then
    utils.warn 'Server is already running'
    return
  end
  server = luv.new_tcp()
  if not server then
    utils.err 'Failed to create server'
    return
  end

  local success, err = pcall(function()
    server:bind('127.0.0.1', config.values.core.port)
  end)

  if not success then
    utils.err('Server bind error: ' .. tostring(err))
    return
  end

  server:listen(128, function(s_err)
    if s_err then
      utils.err('Server error: ' .. s_err)
      return
    end

    client = luv.new_tcp()

    if not client then
      utils.err 'Failed to create client'
      return
    end

    server:accept(client)
    client:read_start(function(c_err, chunk)
      if c_err then
        utils.err('Client read error: ' .. c_err)
        client:close()
        return
      end

      if not chunk then
        return
      end

      if chunk == 'shutdown' then
        stop_server()
        return
      end

      vim.schedule(function()
        chunk = string.match(chunk, '^.+\r\n(.+)$') ---@type string
        local data = vim.json.decode(chunk)

        if not data.languages.java.taskClass then
          return
        end

        vim.schedule(function()
          if not data then
            return
          end

          local sources = {}

          for key, _ in pairs(config.values.commands) do
            table.insert(sources, key)
          end

          picker:select(sources, function(source)
            local test_class_snake = utils.to_snake_case(data.languages.java.taskClass)
            local filepath = string.format('%s/.ast/%s.json', fs.find_root() or fs.make_root(), test_class_snake)
            fs.write(filepath, chunk)

            if not source then
              return
            end

            local extension = config.values.commands[source].extension
            vim.cmd(string.format('edit %s.%s | write', test_class_snake, extension))

            if not config.values.commands[source].template then
              return
            end

            utils.info('populating with ' .. config.values.commands[source].template)
            vim.cmd(string.format('0read %s', config.values.commands[source].template))
          end)
        end)
      end)
    end)
  end)
end

function tcp.bind_server()
  local config = require 'assistant.config'
  is_port_in_use('127.0.0.1', config.values.core.port, function(in_use)
    if in_use then
      local stop_signal = luv.new_tcp()

      if not stop_signal then
        return
      end

      stop_signal:connect('127.0.0.1', config.values.core.port, function(err)
        if not err then
          stop_signal:write('shutdown', function()
            stop_signal:close()
            wait_for_unbind('127.0.0.1', config.values.core.port, 1, 5, start_server)
          end)
          return
        end
        start_server()
      end)
      return
    end
    start_server()
  end)
end

return tcp
