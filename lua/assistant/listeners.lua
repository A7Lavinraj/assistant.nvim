local maps = require("assistant.mappings")
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
        ui.render_input(number)
        ui.render_output(number)
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
        if vim.tbl_contains({ ui.home.buf, ui.input.buf, ui.output.buf }, event.buf) then
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
        ui.input:bo("modifiable", false)
        ui.output:bo("modifiable", false)

        -- Utility keys
        maps.set("n", "q", ui.close, ui.home.buf)
        maps.set("n", "r", runner.push_unique, ui.home.buf)
        maps.set("n", "R", runner.push_all, ui.home.buf)
        maps.set("n", "c", runner.create_test, ui.home.buf)
        maps.set("n", "d", runner.remove_test, ui.home.buf)
        maps.set("n", "i", ui.prompt_hide_and_save_input, ui.home.buf)
        maps.set("n", "e", ui.prompt_hide_and_save_expect, ui.home.buf)

        -- Navigation keys
        maps.set("n", "<c-l>", ui.move_right, ui.home.buf)
        maps.set("n", "<c-j>", ui.move_down, ui.home.buf)
        maps.set("n", "<c-k>", ui.move_up, ui.actions.buf)
        maps.set("n", "<c-l>", ui.move_right, ui.actions.buf)
        maps.set("n", "<c-j>", ui.move_down, ui.input.buf)
        maps.set("n", "<c-h>", ui.move_left, ui.input.buf)
        maps.set("n", "<c-k>", ui.move_up, ui.output.buf)
        maps.set("n", "<c-h>", ui.move_left, ui.output.buf)
      end,
    },
  },
  {
    event = "BufEnter",
    opts = {
      callback = function(event)
        if
          not vim.tbl_contains(
            { ui.home.buf, ui.actions.buf, ui.input.buf, ui.output.buf, ui.prompt.buf, ui.popup.buf },
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
