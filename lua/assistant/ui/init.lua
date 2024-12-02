local Float = require("assistant.ui.float")
local Text = require("assistant.ui.text")
local maps = require("assistant.mappings")
local store = require("assistant.store")
local utils = require("assistant.utils")

local M = {}
M.is_open = false
M.home = setmetatable({ enter = true }, { __index = Float })
M.input = setmetatable({}, { __index = Float })
M.output = setmetatable({}, { __index = Float })
M.prompt = setmetatable({ enter = true }, { __index = Float })
M.view_config = { relative = "editor", style = "minimal", border = "rounded", title_pos = "center" }

-- TODO: fix overflow ui for very small window
function M.update_layout()
  local vh, vw = utils.get_view_port()
  local wh = math.ceil(vh * 0.7) - 2
  local ww = math.ceil(vw * 0.7) - 2
  local rr = math.ceil(vh * 0.5) - math.ceil(wh * 0.5) - 1
  local cr = math.ceil(vw * 0.5) - math.ceil(ww * 0.5) - 1

  if not store.PROBLEM_DATA then
    store.PROBLEM_DATA = {}
  end

  if not store.PROBLEM_DATA["name"] then
    local name = vim.fn.expand("%:t")

    if name == "" then
      store.PROBLEM_DATA["name"] = "UNTITLED"
    else
      store.PROBLEM_DATA["name"] = name
    end
  end

  -- update view config
  M.home.conf = vim.tbl_deep_extend("force", {
    title = " " .. store.PROBLEM_DATA["name"] .. " ",
    height = math.ceil(vh * 0.7),
    width = math.ceil(ww * 0.5),
    row = rr - 1,
    col = cr - 1,
  }, M.view_config)

  M.input.conf = vim.tbl_deep_extend("force", {
    title = " INPUT ",
    height = math.ceil(wh * 0.5),
    width = ww - math.ceil(ww * 0.5),
    row = rr - 1,
    col = cr + math.ceil(ww * 0.5) + 1,
  }, M.view_config)

  M.output.conf = vim.tbl_deep_extend("force", {
    title = " OUTPUT ",
    height = wh - math.ceil(wh * 0.5),
    width = ww - math.ceil(ww * 0.5),
    row = rr + math.ceil(wh * 0.5) + 1,
    col = cr + math.ceil(ww * 0.5) + 1,
  }, M.view_config)

  M.prompt.conf = vim.tbl_deep_extend("force", {
    height = math.floor(vh * 0.5),
    width = math.floor(vw * 0.5),
    row = math.floor(vh * 0.5) - math.floor(vh * 0.25),
    col = math.floor(vw * 0.5) - math.floor(vw * 0.25),
  }, M.view_config)

  -- apply view config
  if M.home:is_win() then
    vim.api.nvim_win_set_config(M.home.win, M.home.conf)
  end

  if M.input:is_win() then
    vim.api.nvim_win_set_config(M.input.win, M.input.conf)
  end

  if M.output:is_win() then
    vim.api.nvim_win_set_config(M.output.win, M.output.conf)
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

  if not store.PROBLEM_DATA then
    store.PROBLEM_DATA = {}
  end

  if not store.PROBLEM_DATA["tests"] then
    store.PROBLEM_DATA["tests"] = {}
  end

  for i, test in ipairs(store.PROBLEM_DATA["tests"]) do
    content:append(string.format("testcase #%d ", i), "AssistantText")

    if test.status == "PASSED" then
      content:append(test.status, "AssistantGreen")
    end

    if test.status == "FAILED" then
      content:append(test.status, "AssistantRed")
    end

    if test.status == "RUNNING" or test.status == "COMPILING" then
      content:append(test.status, "AssistantYellow")
    end

    if
      test.status == "PASSED"
      or test.status == "FAILED"
      or test.status == "COMPILATION ERROR"
      or test.status == "TIME LIMIT EXCEEDED"
    then
      content:append(string.format("takes %.3fs", (test.end_at - test.start_at) * 0.001), "AssistantDimText")
    end

    if i ~= #store.PROBLEM_DATA["tests"] then
      content:nl()
    end
  end

  utils.render(M.home.buf, content)
end

-- Render text for `input` section by testcase `id` as parameter
---@param id number?
function M.render_input(id)
  if not id then
    return
  end

  local content = Text.new()
  local tc = store.PROBLEM_DATA["tests"][id]
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

  utils.render(M.input.buf, content)
end

-- Render output section by testcase `id` as parameter
---@param id number?
function M.render_output(id)
  if not id then
    return
  end

  local content = Text.new()
  local tc = store.PROBLEM_DATA["tests"][id]

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

  utils.render(M.output.buf, content)
end

-- Open Assistant.nvim UI
function M.open()
  store.fetch()
  M.update_layout()
  M.home:create()
  M.input:create()
  M.output:create()
  M.is_open = true
  utils.emit("AssistantViewOpen")
end

-- Close Assistant.nvim UI
function M.close()
  M.home:remove()
  M.input:remove()
  M.output:remove()
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

  if buf == M.input.buf or buf == M.output.buf then
    vim.fn.win_gotoid(M.home.win)
  end
end

-- Focus available right window
function M.move_right()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.home.buf then
    vim.fn.win_gotoid(M.input.win)
  end
end

-- Focus available up window
function M.move_up()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.output.buf then
    vim.fn.win_gotoid(M.input.win)
  end
end

-- Focus available down window
function M.move_down()
  local buf = vim.api.nvim_get_current_buf()

  if buf == M.input.buf then
    vim.fn.win_gotoid(M.output.win)
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
      if store.PROBLEM_DATA["tests"][index].input then
        vim.api.nvim_buf_set_lines(
          M.prompt.buf,
          0,
          -1,
          false,
          vim.split(store.PROBLEM_DATA["tests"][index].input, "\n")
        )
      end
    end,
    post = function()
      local lines = vim.api.nvim_buf_get_lines(M.prompt.buf, 0, -1, false)
      M.prompt_hide()
      store.PROBLEM_DATA["tests"][index].input = table.concat(lines, "\n")
      store.write()
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
      if store.PROBLEM_DATA["tests"][index].output then
        vim.api.nvim_buf_set_lines(
          M.prompt.buf,
          0,
          -1,
          false,
          vim.split(store.PROBLEM_DATA["tests"][index].output, "\n")
        )
      end
    end,
    post = function()
      local lines = vim.api.nvim_buf_get_lines(M.prompt.buf, 0, -1, false)
      M.prompt_hide()
      store.PROBLEM_DATA["tests"][index].output = table.concat(lines, "\n")
      store.write()
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
  maps.set("n", "<m-cr>", opts.post, M.prompt.buf)
end

return M
