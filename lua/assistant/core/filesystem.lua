local opts = require("assistant.config").opts
local utils = require("assistant.utils")
local FileSystem = {}
local luv = vim.uv or vim.loop

local snacks_status, snacks = pcall(require, "snacks")

local function custom_picker(items, on_choice)
  if not snacks_status then
    utils.notify_warn("Snacks.nvim not found, Please visit setup guide in README.md")
    vim.ui.select(items, { prompt = "Sources" }, on_choice)
  else
    local picker_opts = {
      prompt = "sources",
      format_item = function(item)
        return item
      end,
      kind = "string",
    }

    local finder_items = {}
    for idx, item in ipairs(items) do
      table.insert(finder_items, {
        formatted = item,
        text = idx .. " " .. item,
        item = item,
        idx = idx,
      })
    end

    snacks.picker.pick({
      source = "select",
      items = finder_items,
      format = snacks.picker.format.ui_select(picker_opts.kind, #items),
      title = picker_opts.prompt,
      layout = "vscode",
      actions = {
        confirm = function(picker, item)
          picker:close()
          vim.schedule(function()
            on_choice(item and item.item, item and item.idx)
          end)
        end,
      },
      on_close = function()
        vim.schedule(on_choice)
      end,
    })
  end
end

function FileSystem.new()
  return setmetatable({}, { __index = FileSystem })
end

function FileSystem.__init__()
  if vim.fn.isdirectory(".ast") == 0 then
    vim.fn.mkdir(".ast")
  end
end

---@param chunk string
---@return table?
function FileSystem.filter(chunk)
  local parsed = vim.json.decode(chunk)

  if parsed then
    local filtered_data = {}
    filtered_data["name"] = parsed["name"]
    filtered_data["tests"] = parsed["tests"]
    return filtered_data
  end

  return nil
end

---@param filename string
function FileSystem.create(filename)
  local sources = {}

  for key, _ in pairs(opts.commands) do
    table.insert(sources, key)
  end

  custom_picker(sources, function(source)
    if source then
      local extension = opts.commands[source].extension
      vim.cmd(string.format("edit %s.%s | w", filename, extension))

      if opts.commands[source].template then
        utils.notify_info("populating with " .. opts.commands[source].template)
        vim.cmd(string.format("0read %s", opts.commands[source].template))
      end
    end
  end)
end

---@param path string
---@param mode string
---@return string?
function FileSystem.read(path, mode)
  local fd, _ = luv.fs_open(path, mode, 438)

  if not fd then
    return
  end

  local stat = luv.fs_fstat(fd)
  local file_size = stat and stat.size or 0
  local data = luv.fs_read(fd, file_size)
  luv.fs_close(fd)
  return data
end

---@param path string
---@param bytes string
function FileSystem:write(path, bytes)
  self.__init__()
  local fd, _ = luv.fs_open(path, "w", 438)

  if not fd then
    print("[ERROR]: can't open file", path)
    return
  end

  luv.fs_write(fd, bytes)
  luv.fs_close(fd)
end

---@param chunk string
function FileSystem:save(chunk)
  self.__init__()
  chunk = string.match(chunk, "^.+\r\n(.+)$")

  local data = vim.json.decode(chunk)

  if data.languages.java.taskClass then
    vim.schedule(function()
      local filtered_data = self.filter(chunk)
      local task_class_snake = utils.to_snake_case(data.languages.java.taskClass) -- Convert to snake_case
      local filepath = string.format("%s/.ast/%s.json", vim.fn.expand("%:p:h"), task_class_snake)

      if filtered_data then
        self:write(filepath, vim.json.encode(filtered_data))
        self.create(task_class_snake)
      end
    end)
  end
end

---@param path string | nil
---@return table | nil
function FileSystem.fetch(path)
  if not path then
    return nil
  end

  local fd = luv.fs_open(path, "r", 438)

  if not fd then
    return nil
  end

  local stat = vim.loop.fs_fstat(fd)

  if not stat then
    return nil
  end

  local data = vim.loop.fs_read(fd, stat.size, 0)

  if (not data) or (data:gsub("\r\n", "\n") == "") then
    return nil
  end

  vim.loop.fs_close(fd)
  return vim.json.decode(data)
end

return FileSystem
