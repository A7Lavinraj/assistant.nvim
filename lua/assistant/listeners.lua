local runner = require("assistant.runner")
local state = require("assistant.state")
local ui = require("assistant.ui")
local utils = require("assistant.utils")
local M = {}
M.ids = {}
M.augroup = vim.api.nvim_create_augroup("AssistantGroup", { clear = true })
M.cmds = {
  {
    event = "CursorMoved",
    opts = {
      callback = function(event)
        if event.buf ~= ui.home.buf then
          return
        end

        local number = utils.get_current_line_number()
        ui.render_logs(number)
      end,
    },
  },
  {
    event = "VimResized",
    opts = {
      callback = ui.update_layout,
    },
  },
  {
    event = "WinClosed",
    opts = {
      callback = function(event)
        if vim.tbl_contains({ ui.home.buf, ui.logs.buf, ui.logs.buf }, event.buf) then
          ui.close()
        end

        if event.buf == ui.prompt.buf then
          ui.prompt_hide()
        end

        if event.buf == ui.popup.buf then
          ui.popup_hide()
        end
      end,
    },
  },
  {
    event = "User",
    opts = {
      pattern = "AssistantViewOpen",
      callback = function()
        require("assistant.ui.groups").setup()
        ui.render_home()

        -- default options
        ui.home:bo("modifiable", false)
        ui.actions:bo("modifiable", false)
        ui.logs:bo("modifiable", false)
        ui.logs:bo("modifiable", false)

        -- Utility keys
        vim.keymap.set("n", "q", ui.close, { buffer = ui.home.buf })
        vim.keymap.set("n", "q", ui.close, { buffer = ui.actions.buf })
        vim.keymap.set("n", "q", ui.close, { buffer = ui.logs.buf })
        vim.keymap.set("n", "r", runner.push_unique, { buffer = ui.home.buf })
        vim.keymap.set("n", "R", runner.push_all, { buffer = ui.home.buf })
        vim.keymap.set("n", "c", runner.create_test, { buffer = ui.home.buf })
        vim.keymap.set("n", "d", runner.remove_test, { buffer = ui.home.buf })
        vim.keymap.set("n", "i", ui.prompt_hide_and_save_input, { buffer = ui.home.buf })
        vim.keymap.set("n", "e", ui.prompt_hide_and_save_expect, { buffer = ui.home.buf })

        -- Navigation keys
        vim.keymap.set("n", "<c-l>", ui.move_right, { buffer = ui.home.buf })
        vim.keymap.set("n", "<c-j>", ui.move_down, { buffer = ui.home.buf })
        vim.keymap.set("n", "<c-k>", ui.move_up, { buffer = ui.actions.buf })
        vim.keymap.set("n", "<c-l>", ui.move_right, { buffer = ui.actions.buf })
        vim.keymap.set("n", "<c-h>", ui.move_left, { buffer = ui.logs.buf })
      end,
    },
  },
  {
    event = "BufEnter",
    opts = {
      callback = function(event)
        if
          not vim.tbl_contains(
            { ui.home.buf, ui.actions.buf, ui.logs.buf, ui.logs.buf, ui.prompt.buf, ui.popup.buf },
            event.buf
          )
        then
          state.set_by_key("need_compilation", function()
            return true
          end)
          ui.close()
        end
      end,
    },
  },
  {
    event = "BufWritePost",
    opts = {
      callback = function()
        state.set_by_key("need_compilation", function()
          return true
        end)
      end,
    },
  },
}

function M.init()
  for _, cmd in ipairs(M.cmds) do
    M.set(cmd.event, cmd.opts)
  end
end

---@param event string
---@param opts vim.api.keyset.create_autocmd
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
