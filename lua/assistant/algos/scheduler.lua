---@class Assistant.Scheduler.Options
---@field max_parallelism? integer

---@class Assistant.Scheduler : Assistant.Scheduler.Options
---@field queue Assistant.Queue
---@field process_count integer
---@field is_running boolean
local Schedular = {}
local luv = vim.uv or vim.loop

---@param options? Assistant.Scheduler.Options
function Schedular.new(options)
  return setmetatable({}, { __index = Schedular }):init(options)
end

---@param opts? Assistant.Scheduler.Options
function Schedular:init(opts)
  opts = opts or {}
  self.max_parallelism = opts.max_parallelism or luv.available_parallelism()
  self.is_running = false
  self.process_count = 0
  self.queue = require('assistant.algos.queue').new()
  return self
end

---@param process thread
function Schedular:schedule(process)
  self.queue:push(process)

  if not self.is_running then
    self:start_processing()
  end
end

function Schedular:start_processing()
  if self.is_running then
    return
  end

  self.is_running = true

  local function process()
    if self.queue:empty() then
      self.is_running = false
      return
    end

    if self.process_count < self.max_parallelism then
      local co = self.queue:pop()

      if co and coroutine.status(co) == 'suspended' then
        self.process_count = self.process_count + 1

        coroutine.resume(co)

        if coroutine.status(co) == 'dead' then
          self.process_count = self.process_count - 1
        else
          vim.defer_fn(function()
            if coroutine.status(co) == 'dead' then
              self.process_count = self.process_count - 1
            else
              vim.defer_fn(function()
                process()
              end, 10)
            end
          end, 10)
        end
      end

      vim.schedule(process)
    else
      vim.defer_fn(process, 10)
    end
  end

  vim.schedule(process)
end

return Schedular
