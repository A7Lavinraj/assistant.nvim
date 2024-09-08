local config = require("assistant.config")

local M = {}

function M.create_source(filename)
  local sources = {}

  for key, _ in pairs(config.commands) do
    table.insert(sources, key)
  end

  vim.ui.select(sources, { prompt = "Select source" }, function(source)
    if source then
      local extension = config.commands[source].extension
      vim.cmd(string.format("edit %s.%s | w", filename, extension))
    end
  end)
end

function M.store_problem(chunk)
  if vim.fn.isdirectory(".ast") == 0 then
    vim.fn.mkdir(".ast")
  end

  local data = string.match(chunk, "^.+\r\n(.+)$")
  local filename = vim.json.decode(data).languages.java.taskClass

  if filename then
    vim.schedule(function()
      local fd = vim.loop.fs_open(string.format("%s/%s/%s.json", vim.fn.expand("%:p:h"), ".ast", filename), "w", 438)

      if fd then
        vim.loop.fs_write(fd, (tostring(data)))
        vim.loop.fs_close(fd)
        M.create_source(filename)
      end
    end)
  end
end

function M.load()
  ---@diagnostic disable: undefined-field
  local server = vim.loop.new_tcp()

  server:bind("127.0.0.1", 10043)
  server:listen(128, function(listening_error)
    assert(not listening_error, listening_error)
    local client = vim.loop.new_tcp()
    server:accept(client)
    client:read_start(function(read_error, chunk)
      assert(not read_error, read_error)

      if chunk then
        vim.schedule(function()
          M.store_problem(chunk)
        end)
      else
        client:shutdown()
        client:close()
      end
    end)
  end)

  vim.loop.run()
end

return M
