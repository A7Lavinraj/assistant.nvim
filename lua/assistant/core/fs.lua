local fs = {}
local luv = vim.uv or vim.loop

---@return string|nil
function fs.find_root()
  local current_dir = luv.cwd()

  while current_dir ~= '/' do
    local ast_dir = string.format('%s/%s', current_dir, '.ast')
    if vim.fn.isdirectory(ast_dir) == 1 then
      return current_dir
    end
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end

  if vim.fn.isdirectory '/.ast' == 1 then
    return '/'
  end

  return nil
end

---@return string
function fs.make_root()
  local fallback_dir = vim.fn.expand '%:p:h'
  local ast_path = string.format('%s/.ast', fallback_dir)
  luv.fs_mkdir(ast_path, 493)
  return fallback_dir
end

---@return string|nil
function fs.get_state_filepath()
  local state = require 'assistant.state'
  if state.get_global_key 'filename' == '' and state.get_global_key 'extension' == '' then
    return nil
  end
  local root_dir = fs.find_root()
  if not root_dir then
    return nil
  end
  return ('%s/.ast/%s.json'):format(root_dir, require('assistant.state').get_global_key 'filename')
end

---@param path string
---@return string?
function fs.read(path)
  local fd, _ = luv.fs_open(path, 'r', 420)

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
function fs.write(path, bytes)
  local fd, _ = luv.fs_open(path, 'w', 438)

  if not fd then
    print('[ERROR]: can\'t open file', path)
    return
  end

  luv.fs_write(fd, bytes)
  luv.fs_close(fd)
end

return fs
