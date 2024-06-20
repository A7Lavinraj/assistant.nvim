local State = require("assistant.ui.state")
local Window = require("assistant.ui.window")
local renderer = require("assistant.ui.renderer")
local store = require("assistant.store")
local transformer = require("assistant.ui.transformer")

local M = {}

local window = Window.new(State.new())

function M.render_tab()
  if store.TAB == 1 then
    renderer.render(window.state.buf, transformer.merge(transformer.tabs(), transformer.problem()))
  elseif store.TAB == 2 then
    renderer.render(window.state.buf, transformer.merge(transformer.tabs(), transformer.testcases()))
  end
end

function M.open_window()
  window:create()
end

function M.close_window()
  window:remove()
end

function M.toggle_window()
  window:toggle()
end

function M.resize_window()
  window:resize()
end

function M.write_start()
  window:write_start()
end

function M.write_stop()
  window:write_stop()
end

function M.on_key(mode, lhs, rhs)
  window:on_key(mode, lhs, rhs)
end

function M.is_buf()
  window:is_buf()
end

function M.is_win()
  window:is_win()
end

function M.get_state()
  return window.state
end

return M
