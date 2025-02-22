local AstLayout = require("assistant.ui.layout")
local AstRender = require("assistant.ui.render")
local AstRunner = require("assistant.core.runner")
local AstText = require("assistant.ui.text")
local state = require("assistant.core.state")
local utils = require("assistant.utils")
local opts = require("assistant.config").opts

local M = {}

function M.create()
  local self = setmetatable({}, { __index = setmetatable(M, { __index = AstLayout }) })

  AstLayout._init(self, {
    width = opts.ui.width,
    height = opts.ui.height,
    backdrop = opts.ui.backdrop,
    border = opts.ui.border,
    zindex = 1,
    pane_config = {
      Tasks = {
        startup = true,
        enter = true,
        style = "minimal",
        relative = "editor",
        width = 0.4,
        height = 1,
        dheight = -3,
        title = " Tasks " .. opts.ui.tasks.title_icon,
      },
      Actions = {
        startup = true,
        style = "minimal",
        relative = "editor",
        dheight = 1,
        width = 0.4,
        bottom = "Tasks",
        border = opts.ui.actions.border,
        title = " Actions " .. opts.ui.tasks.title_icon,
      },
      Logs = {
        startup = true,
        style = "minimal",
        relative = "editor",
        width = 0.6,
        height = 1,
        right = "Tasks",
        border = opts.ui.logs.border,
        title = " Logs " .. opts.ui.tasks.title_icon,
      },
      Edit = {
        enter = true,
        modifiable = true,
        style = "minimal",
        relative = "editor",
        width = 0.5,
        height = 0.5,
        row = 3,
        col = 3,
        zindex = 3,
        border = opts.ui.logs.border,
        title = " Edit (enter to confirm) " .. opts.ui.tasks.title_icon,
      },
      Popup = {
        enter = true,
        style = "minimal",
        relative = "editor",
        width = 0.8,
        height = 0.8,
        row = 2,
        col = 1.8,
        zindex = 3,
        border = opts.ui.logs.border,
        title = " Popup (q to close) " .. opts.ui.tasks.title_icon,
      },
    },
  })

  self.text = AstText.new()

  self.render = AstRender.new(self)

  self.runner = AstRunner.new(self)

  return self
end

function M.init()
  if M.setup then
    return
  end

  M.view:bind_cmd("VimResized", function()
    M.view:resize()
  end)

  M.setup = true
end

function M.show()
  M.view = M.view or M.create()

  if M.view.is_open then
    return
  end

  M.init()

  state.update()

  M.view:open()

  local winhls = { "NormalFloat", "FloatBorder", "FloatTitle" }

  for name, config in pairs(M.view.pane_config) do
    local winhl = ""

    for index, hl in ipairs(winhls) do
      if index ~= 1 then
        winhl = winhl .. ","
      end

      winhl = winhl .. string.format("%s:Ast%s%s", hl, name, hl)
    end

    utils.wo(config.win, "winhighlight", winhl)

    if name == "Tasks" then
      utils.wo(config.win, "cursorline", true)
    end

    if M.view.backdrop and name == "Backdrop" then
      utils.wo(config.win, "winblend", M.view.backdrop)
    end
  end

  for name, config in pairs(M.view.pane_config) do
    if vim.tbl_contains({ "Tasks", "Actions", "Logs" }, name) then
      M.view:bind_cmd("WinClosed", function()
        M.view:close()
      end, { buffer = config.buf })

      M.view:bind_key("q", function()
        M.view:close()
      end, { buffer = config.buf })
    end
  end

  M.view:bind_cmd("BufWritePost", function()
    state.set_by_key("need_compilation", function()
      return true
    end)

    state.write_all()
  end)

  M.view:bind_cmd("CursorMoved", function()
    local line = vim.api.nvim_get_current_line()

    if line:match("^%s*.+%s*Testcase #%d+") then
      local id = tonumber(line:match("^%s*.+%s*Testcase #(%d+)"))
      M.view.render:render_log(id)
    end
  end, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("j", utils.next_test, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("k", utils.prev_test, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("s", function()
    local test_id = utils.get_current_line_number()

    if test_id then
      state.set_by_key("tests", function(value)
        if value[test_id].checked then
          value[test_id].checked = false
        else
          value[test_id].checked = true
        end

        return value
      end)

      M.view.render:render_tasks()

      state.write_all()
    end
  end, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("c", function()
    M.view.runner:create_test()

    local line_count = vim.api.nvim_buf_line_count(0)

    if line_count > 0 then
      vim.api.nvim_win_set_cursor(0, { line_count, 0 })
    end

    utils.prev_test()
  end, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("d", function()
    M.view.runner:remove_test()
    utils.prev_test()
  end, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("e", function()
    M.edit()
  end, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("a", function()
    local tests = state.get_all_tests()
    local all_checked = true

    for _, test in ipairs(tests or {}) do
      if not test.checked then
        all_checked = false
        break
      end
    end

    if all_checked then
      state.set_by_key("tests", function(value)
        for i = 1, #value do
          value[i].checked = false
        end

        return value
      end)
    else
      state.set_by_key("tests", function(value)
        for i = 1, #value do
          value[i].checked = true
        end

        return value
      end)
    end

    M.view.render:render_tasks()

    state.write_all()
  end, { buffer = M.view.pane_config.Tasks.buf })

  M.view:bind_key("r", function()
    M.view.runner:push_unique()
  end, { buffer = M.view.pane_config.Tasks.buf })

  M.view.render:render_tasks()

  utils.next_test()
end

function M.popup()
  M.view:open_unique("Popup")

  M.view:bind_key("q", function()
    M.view:close_unique("Popup")
  end, { buffer = M.view.pane_config.Popup.buf })

  M.view:bind_cmd({ "WinClosed", "WinLeave" }, function()
    M.view:close_unique("Popup")
  end, { buffer = M.view.pane_config.Popup.buf })
end

function M.edit()
  local test_id = utils.get_current_line_number()

  if not test_id then
    return
  end

  M.view:open_unique("Edit")

  M.view.render:render_io(test_id)

  M.view:bind_key("<enter>", function()
    local lines = table.concat(vim.api.nvim_buf_get_lines(M.view.pane_config.Edit.buf, 0, -1, false), "\n")

    state.set_by_key("tests", function(value)
      value[test_id].input, value[test_id].output = utils.text_to_io(lines)
      return value
    end)

    state.write_all()

    M.view:close_unique("Edit")
  end, { buffer = M.view.pane_config.Edit.buf })

  M.view:bind_key("q", function()
    M.view.view:close_unique("Edit")
  end, { buffer = M.view.pane_config.Edit.buf })

  M.view:bind_cmd({ "WinClosed", "WinLeave" }, function()
    M.view:close_unique("Edit")
  end, { buffer = M.view.pane_config.Edit.buf })
end

return M
