local Float = require("assistant.ui.float")
local Text = require("assistant.ui.text")
local maps = require("assistant.mappings")
local state = require("assistant.state")
local utils = require("assistant.utils")

local M = {}
M.is_open = false
M.home = setmetatable({ enter = true }, { __index = Float })
M.logs = setmetatable({}, { __index = Float })
M.prompt = setmetatable({ enter = true }, { __index = Float })
M.popup = setmetatable({ enter = true }, { __index = Float })
M.actions = setmetatable({}, { __index = Float })
M.view_config = { relative = "editor", style = "minimal", border = "rounded", title_pos = "center" }

---@return integer, integer, integer, integer
M.get_layout_dimension = function()
  local vh, vw = utils.get_view_port()
  local lh = math.floor(vh * 0.8)
  local lw = math.floor(vw * 0.8)
  local lt = math.floor((vh - lh) / 2) - 1
  local ll = math.floor((vw - lw) / 2) - 2
  return lh, lw, lt, ll
end

function M.update_layout()
  local vh, vw = utils.get_view_port()
  local name = state.get_problem_name()
  local lh, lw, lt, ll = M.get_layout_dimension()

  if not name then
    name = vim.fn.expand("%:t:r")

    if name == "" then
      state.set_by_key("src_name", function()
        return "UNTITLED"
      end)
    else
      state.set_by_key("src_name", function()
        return name
      end)
    end
  end

  -- update view config
  M.home.conf = vim.tbl_deep_extend("force", {
    height = lh - 3,
    width = math.ceil(lw / 3),
    row = lt,
    col = ll,
    title = " " .. name .. " ",
  }, M.view_config)

  M.actions.conf = vim.tbl_deep_extend("force", {
    height = 1,
    width = math.ceil(lw / 3),
    row = lt + lh - 1,
    col = ll,
    title = "  ACTIONS ",
  }, M.view_config)

  M.logs.conf = vim.tbl_deep_extend("force", {
    height = lh,
    width = math.ceil((2 * lw) / 3),
    row = lt,
    col = ll + math.ceil(lw / 3) + 2,
    title = "   LOGS ",
  }, M.view_config)

  M.prompt.conf = vim.tbl_deep_extend("force", {
    height = math.floor(vh * 0.5),
    width = math.floor(vw * 0.5),
    row = math.floor(vh * 0.5) - math.floor(vh * 0.25),
    col = math.floor(vw * 0.5) - math.floor(vw * 0.25),
    footer = { { "[<enter> to confirm changes]", "AssistantGreen" } },
    footer_pos = "center",
  }, M.view_config)

  M.popup.conf = vim.tbl_deep_extend("force", {
    height = math.floor(vh * 0.5),
    width = math.floor(vw * 0.5),
    row = math.floor(vh * 0.5) - math.floor(vh * 0.25),
    col = math.floor(vw * 0.5) - math.floor(vw * 0.25),
    footer = { { "[q to exit]", "AssistantRed" } },
    footer_pos = "center",
  }, M.view_config)

  -- apply view config
  if M.home:is_win() then
    vim.api.nvim_win_set_config(M.home.win, M.home.conf)
  end

  if M.actions:is_win() then
    vim.api.nvim_win_set_config(M.actions.win, M.actions.conf)
  end

  if M.logs:is_win() then
    vim.api.nvim_win_set_config(M.logs.win, M.logs.conf)
  end

  if M.prompt:is_win() then
    vim.api.nvim_win_set_config(M.prompt.win, M.prompt.conf)
  end
end

-- Render text for home section
function M.render_home()
  if not M.home:is_buf() then
    return
  end

  local content = Text.new()
  local tests = state.get_all_tests()

  for i, test in ipairs(tests or {}) do
    content:append(string.format("testcase #%d ", i), "AssistantText")
    content:append(test.status or "", test.group or "AssistantText")

    if test.time_taken then
      content:append(string.format("takes %.3fs", test.time_taken), "AssistantDimText")
    end

    if i ~= #tests then
      content:nl()
    end
  end

  utils.render(M.home.buf, content)
end

-- Render text for `input` section by testcase `id` as parameter
---@param id number?
function M.render_logs(id)
  local content = Text.new()

  if id ~= nil then
    local tc = state.get_test_by_id(id)
    if tc.input then
      content:append("Input", "AssistantH1"):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(tc.input or "", 100)) do
        if line then
          content:append(line, "AssistantText"):nl()
        end
      end

      content:nl()
      local _, cnt = string.gsub(tc.stdout or "", "\n", "")

      if cnt > 100 then
        content:append("-- REACHED MAXIMUM RENDER LIMIT --", "AssistantDimText")
      end
    end

    if tc.output then
      content:append("Expect", "AssistantH1"):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(tc.output or "", 100)) do
        if line then
          content:append(line, "AssistantText"):nl()
        end
      end

      content:nl()
      local _, cnt = string.gsub(tc.stdout or "", "\n", "")

      if cnt > 100 then
        content:append("-- REACHED MAXIMUM RENDER LIMIT --", "AssistantDimText")
      end
    end
  end

  if id ~= nil then
    local tc = state.get_test_by_id(id)

    if tc.stdout and tc.stdout ~= "" then
      content:append("Stdout", "AssistantH1"):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(tc.stdout, 100)) do
        if line then
          content:append(line, "AssistantText"):nl()
        end
      end

      content:nl()
      local _, cnt = string.gsub(tc.stdout or "", "\n", "")

      if cnt > 100 then
        content:append("-- REACHED MAXIMUM RENDER LIMIT --", "AssistantDimText")
      end
    end

    if tc.stderr and tc.stderr ~= "" then
      content:nl():append("Stderr", "AssistantH1"):nl(2)

      for _, line in ipairs(utils.slice_first_n_lines(tc.stderr, 100)) do
        if line then
          content:append(line, "AssistantText"):nl()
        end
      end

      content:nl()
      local _, cnt = string.gsub(tc.stderr or "", "\n", "")

      if cnt > 100 then
        content:append("-- REACHED MAXIMUM RENDER LIMIT --", "AssistantDimText")
      end
    end
  end

  utils.render(M.logs.buf, content)
end

-- Open Assistant.nvim UI
function M.open()
  state.update_all()
  M.update_layout()
  M.home:create()
  M.actions:create()
  M.logs:create()
  M.home:wo("winhighlight", "FloatBorder:AssistantFloatBorder")
  M.actions:wo("winhighlight", "FloatBorder:AssistantFloatBorder")
  M.logs:wo("winhighlight", "FloatBorder:AssistantFloatBorder")
  M.is_open = true
  utils.emit("AssistantViewOpen")
end

-- Close Assistant.nvim UI
function M.close()
  M.home:remove()
  M.actions:remove()
  M.logs:remove()
  M.is_open = false
  utils.emit("AssistantViewClose")
end

-- Toggle Open and Close functionality of UI
function M.toggle()
  if M.is_open then
    M.close()
  else
    M.open()
  end
end

-- Focus available left window
function M.move_left()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.logs.buf then
    vim.fn.win_gotoid(M.home.win)
  end

  if buf == M.logs.buf then
    vim.fn.win_gotoid(M.actions.win)
  end
end

-- Focus available right window
function M.move_right()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.home.buf then
    vim.fn.win_gotoid(M.logs.win)
  end

  if buf == M.actions.buf then
    vim.fn.win_gotoid(M.logs.win)
  end
end

-- Focus available up window
function M.move_up()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.logs.buf then
    vim.fn.win_gotoid(M.logs.win)
  end

  if buf == M.actions.buf then
    vim.fn.win_gotoid(M.home.win)
  end
end

-- Focus available down window
function M.move_down()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.home.buf then
    vim.fn.win_gotoid(M.actions.win)
  end

  if buf == M.logs.buf then
    vim.fn.win_gotoid(M.logs.win)
  end
end

-- Hide prompt window and save text contain in it as `input` block
function M.prompt_hide_and_save_input()
  local current_line = vim.api.nvim_get_current_line()
  local index = tonumber(current_line:match("testcase #(%d+)%s+"))

  if not index then
    return
  end

  M.prompt.conf.title = " edit INPUT "
  M.prompt_show({
    pre = function()
      if state.get_test_by_id(index).input then
        vim.api.nvim_buf_set_lines(M.prompt.buf, 0, -1, false, vim.split(state.get_test_by_id(index).input, "\n"))
      end
    end,
    post = function()
      local lines = vim.api.nvim_buf_get_lines(M.prompt.buf, 0, -1, false)
      M.prompt_hide()
      state.get_test_by_id(index).input = table.concat(lines, "\n")
    end,
  })
end

-- Hide prompt window and save text contain in it as `expect` block
function M.prompt_hide_and_save_expect()
  local current_line = vim.api.nvim_get_current_line()
  local index = tonumber(current_line:match("testcase #(%d+)%s+"))

  if not index then
    return
  end

  M.prompt.conf.title = " edit OUTPUT "
  M.prompt_show({
    pre = function()
      if state.get_test_by_id(index).output then
        vim.api.nvim_buf_set_lines(M.prompt.buf, 0, -1, false, vim.split(state.get_test_by_id(index).output, "\n"))
      end
    end,
    post = function()
      local lines = vim.api.nvim_buf_get_lines(M.prompt.buf, 0, -1, false)
      M.prompt_hide()
      state.get_test_by_id(index).output = table.concat(lines, "\n")
    end,
  })
end

-- Hide the prompt window without saving the text inside it
function M.prompt_hide()
  M.prompt:remove()
end

-- Opens the prompt window with `pre` and `post` actions supported
---@param opts {pre:function,post:function}
function M.prompt_show(opts)
  M.prompt:create()
  opts.pre()
  maps.set("n", "<cr>", opts.post, M.prompt.buf)
end

function M.popup_hide()
  M.popup:remove()
end

---@param text AssistantText
function M.popup_show(text)
  M.popup.conf.title = " Compilation Error "
  M.popup:create()
  M.popup:bo("modifiable", false)
  utils.render(0, text)
  maps.set("n", "q", M.popup_hide, M.popup.buf)
end

return M
