local Text = require("assistant.ui.text")
local config = require("assistant.config")
local constants = require("assistant.constants")
local store = require("assistant.store")
local utils = require("assistant.utils")
local AssisstantTransformer = {}

---@param a AssistantText
---@param b AssistantText
---@return AssistantText
function AssisstantTransformer.merge(a, b)
  local text = Text.new()
  text.lines = a.lines

  for _, line in pairs(b.lines) do
    table.insert(text.lines, line)
  end

  return text
end

---@return AssistantText
function AssisstantTransformer.tabs()
  local text = Text.new()

  for i = 1, #config.tabs do
    config.tabs[i].isActive = false
  end

  config.tabs[store.TAB].isActive = true
  text:nl()

  for i = 1, #config.tabs do
    text:append(config.tabs[i].title, config.tabs[i].isActive and "AssistantButtonActive" or "AssistantButton")
  end

  return text
end

function AssisstantTransformer.header()
  local text = Text.new()

  if store.PROBLEM_DATA then
    text:nl()
    text:append(string.format("%s", store.PROBLEM_DATA["name"] or "Untitled"), "AssistantH1")
    text:nl(2)

    if store.PROBLEM_DATA["timeLimit"] then
      text:append(
        string.format("Time limit: %.2f seconds", store.PROBLEM_DATA["timeLimit"] / 1000),
        "AssistantFadeText"
      )
    else
      text:append("Time limit: Unknown,", "AssistantFadeText")
    end

    if store.PROBLEM_DATA["memoryLimit"] then
      text:append(string.format("Memory limit: %s MB", store.PROBLEM_DATA["memoryLimit"]), "AssistantFadeText")
    else
      text:append("Memory limit: Unknown", "AssistantFadeText")
    end
  else
    text:nl()
    text:append("No sample found", "AssistantFadeText")
  end

  return text
end

---@return AssistantText
function AssisstantTransformer.tests_list()
  local text = Text.new():nl()

  if not (store.PROBLEM_DATA and store.PROBLEM_DATA["tests"]) then
    text:append("No sample found", "AssistantFadeText"):nl()
  else
    for index, test in ipairs(store.PROBLEM_DATA["tests"]) do
      text
        :append(test.expand and "" or "", "AssistantNote")
        :append(string.format("Testcase #%d:", index), "AssistantNote")

      if store.COMPILE_STATUS.code and store.COMPILE_STATUS.code ~= 0 then
        text:append("COMPILATION FAILED", "AssistantError")
      else
        if not test.status then
          text:append("READY", "AssistantText")
        elseif test.status == "PASSED" then
          text:append("PASSED", "AssistantPassed")
        elseif test.status == "FAILED" then
          text:append("FAILED", "AssistantFailed")
        elseif test.status == "COMPILING" then
          text:append("COMPILING", "AssistantCompiling")
        elseif test.status == "RUNNING" then
          text:append("RUNNING", "AssistantRunning")
        elseif test.status == "TIME LIMIT EXCEEDED" then
          text:append("TIME LIMIT EXCEEDED", "AssistantFailed")
        else
          text:append("UNKNOWN", "AssistantFailed")
        end
      end

      text:nl(2)
    end
  end

  return text
end

---@param tc_number number | nil
---@param win number | nil
---@return AssistantText
function AssisstantTransformer.testcase(tc_number, win)
  local text = Text.new()

  if store.COMPILE_STATUS and store.COMPILE_STATUS.code ~= 0 and store.COMPILE_STATUS.error then
    for _, line in ipairs(store.COMPILE_STATUS.error) do
      text:append(line, "AssistantFadeText"):nl()
    end

    return text
  end

  if not tc_number then
    return utils.text_center(text, "Hold the cursor on any testcase", "AssistantFadeText", win) or text
  end

  if store.PROBLEM_DATA and store.PROBLEM_DATA["tests"] then
    local test = store.PROBLEM_DATA["tests"][tc_number]

    if test.status ~= "RUNNING" then
      text:nl()
      text:append("  INPUT", "AssistantFadeText"):nl()
      local lines = vim.split(test.input, "\n")

      for i = 1, math.min(#lines, constants.MAX_RENDER_LIMIT) do
        text:nl()
        text:append("  " .. lines[i], "AssistantText")
      end

      if #lines > constants.MAX_RENDER_LIMIT then
        text:append("...Data is too large to render", "AssistantFadeText")
      end

      text:nl()
      text:append("  EXPECTED", "AssistantFadeText"):nl()

      lines = vim.split(test.output, "\n")

      for i = 1, math.min(#lines, constants.MAX_RENDER_LIMIT) do
        text:nl()
        text:append("  " .. lines[i], "AssistantText")
      end

      if #lines > constants.MAX_RENDER_LIMIT then
        text:append("...Data is too large to render", "AssistantFadeText")
      end

      if test.stdout and test.stdout ~= "" then
        text:nl()
        text:append("  STDOUT", "AssistantFadeText"):nl()

        lines = vim.split(test.stdout, "\n")

        for i = 1, math.min(#lines, constants.MAX_RENDER_LIMIT) do
          text:nl()
          text:append("  " .. lines[i], "AssistantText")
        end

        if #lines > constants.MAX_RENDER_LIMIT then
          text:append("...Data is too large to render", "AssistantFadeText")
        end
      end

      if test.stderr and test.stderr ~= "" then
        text:nl()
        text:append("  STDERR", "AssistantFadeText"):nl()

        if test.stderr and test.stderr ~= "" then
          lines = vim.split(test.stderr, "\n")

          for i = 1, math.min(#lines, constants.MAX_RENDER_LIMIT) do
            text:nl()
            text:append("  " .. lines[i], "AssistantText")
          end

          if #lines > constants.MAX_RENDER_LIMIT then
            text:append("...Data is too large to render", "AssistantFadeText")
          end
        end
      end
    end
  end

  return text
end

return AssisstantTransformer
