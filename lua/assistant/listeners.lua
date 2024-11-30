local maps = require("assistant.mappings")
local prompt = require("assistant.ui.prompt")
local runner = require("assistant.runner")
local ui = require("assistant.ui")
local M = {}

M.ids = {}
M.augroup = vim.api.nvim_create_augroup("AssistantGroup", { clear = true })
M.cmds = {
  {
    event = "CursorMoved",
    opts = {
      callback = function()
        local current_line = vim.api.nvim_get_current_line()
        local number = tonumber(current_line:match("testcase #(%d+)%s+"))

        if number then
          ui.render:input(number)
          ui.render:output(number)
        end
      end,
    },
  },
  {
    event = "VimResized",
    opts = {
      callback = function()
        ui.resize()
        prompt.resize()
      end,
    },
  },
  {
    event = "WinClosed",
    opts = {
      callback = function(event)
        for i = 1, 2 do
          for j = 1, 2 do
            if event.buf == ui.view[i][j].buf then
              ui.close()
              goto done
            end
          end
        end

        if event.buf == prompt.float.buf then
          prompt.hide()
        end

        ::done::
      end,
    },
  },
  {
    event = "User",
    opts = {
      pattern = "AssistantViewOpen",
      callback = function()
        ui.render:home()

        for i = 1, 2 do
          for j = 1, 2 do
            if i == 1 and j == 1 then
              maps.set("n", "r", runner.run_unique, ui.view[i][j].buf)
              maps.set("n", "R", runner.run_all, ui.view[i][j].buf)
              maps.set("n", "c", runner.create_test, ui.view[i][j].buf)
              maps.set("n", "d", runner.remove_test, ui.view[i][j].buf)
              maps.set("n", "i", prompt.hide_and_save_input, ui.view[i][j].buf)
              maps.set("n", "e", prompt.hide_and_save_expect, ui.view[i][j].buf)
            end

            maps.set("n", "<c-h>", ui.move_left, ui.view[i][j].buf)
            maps.set("n", "<c-l>", ui.move_right, ui.view[i][j].buf)
            maps.set("n", "<c-k>", ui.move_up, ui.view[i][j].buf)
            maps.set("n", "<c-j>", ui.move_down, ui.view[i][j].buf)
          end
        end
      end,
    },
  },
}

function M.init()
  for _, cmd in ipairs(M.cmds) do
    M.set(cmd.event, cmd.opts)
  end
end

function M.set(event, opts)
  local id = vim.api.nvim_create_autocmd(event, vim.tbl_deep_extend("force", opts, { group = M.augroup }))
  table.insert(M.ids, id)
end

function M.clear_all()
  for _, id in ipairs(M.ids) do
    vim.api.nvim_del_autocmd(id)
  end
end

return M
