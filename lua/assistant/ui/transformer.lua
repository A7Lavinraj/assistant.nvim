local Text = require("assistant.ui.text")
local config = require("assistant.config")
local store = require("assistant.store")
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

function AssisstantTransformer.problem()
  local text = Text.new()

  if store.PROBLEM_DATA then
    text:nl()
    text:append(string.format("%s", store.PROBLEM_DATA["name"]), "AssistantH1")
    text:nl(2)
    text:append(string.format("Time limit: %.2f seconds", store.PROBLEM_DATA["timeLimit"] / 1000), "AssistantFadeText")
    text:append(string.format("Memory limit: %s MB", store.PROBLEM_DATA["memoryLimit"]), "AssistantFadeText")
    text:nl(2)

    for index, test in ipairs(store.PROBLEM_DATA["tests"]) do
      text:append(string.format("SAMPLE #%d", index), "AssistantNote")
      text:nl(2)
      text:append("  INPUT", "AssistantFadeText")
      text:nl()

      for _, value in ipairs(vim.split(test.input, "\n")) do
        text:nl()
        text:append("  " .. value, "AssistantText")
      end

      text:nl(2)
      text:append("  EXPECTED", "AssistantFadeText")
      text:nl()

      for _, value in ipairs(vim.split(test.output, "\n")) do
        text:nl()
        text:append("  " .. value, "AssistantText")
      end

      text:nl()
    end
  else
    text:nl()
    text:append("No sample found", "AssistantFadeText")
  end

  return text
end

---@class Test
---@field input string
---@field output string
---@field stdout string
---@field stderr string
---@field status string
---@field start_at number
---@field end_at number
---@field group string
---@field expand boolean

---@return AssistantText
function AssisstantTransformer.testcases()
  local text = Text.new()

  if not (store.PROBLEM_DATA and store.PROBLEM_DATA["tests"]) then
    text:nl()
    text:append("No sample found", "AssistantFadeText")
  else
    if store.COMPILE_STATUS.code and store.COMPILE_STATUS.code ~= 0 then
      text:nl()
      text:append("COMPILATION FAILED", "AssistantError")
      text:nl(2)

      for _, line in pairs(store.COMPILE_STATUS.error) do
        text:append(line, "AssistantFadeText")
        text:nl()
      end

      for i = 1, #store.PROBLEM_DATA["tests"] do
        store.PROBLEM_DATA["tests"][i].status = "COMPILATION FAILED"
        store.PROBLEM_DATA["tests"][i].group = "AssistantError"
      end
    end

    for index, test in ipairs(store.PROBLEM_DATA["tests"]) do
      text:nl()
      text:append(test.expand and "" or "", "AssistantReady")
      text:append(string.format("Testcase #%d:", index), "AssistantNote")
      text:append(string.format("%s", test.status or "READY"), test.group or "AssistantReady")

      if test.start_at and test.end_at then
        text:append(string.format("takes %.3f seconds", (test.end_at - test.start_at) / 1000), "AssistantFadeText")
      end

      text:nl()

      if test.expand and test.expand == true and test.status ~= "RUNNING" then
        text:nl()
        text:append("  INPUT", "AssistantNote")
        text:nl()

        for _, line in ipairs(vim.split(test.input, "\n")) do
          text:nl()
          text:append("  " .. line, "AssistantText")
        end

        text:nl(2)
        text:append("  EXPECTED", "AssistantNote")
        text:nl()

        for _, line in ipairs(vim.split(test.output, "\n")) do
          text:nl()
          text:append("  " .. line, "AssistantText")
        end

        if test.stdout and test.stdout ~= "" then
          text:nl(2)
          text:append("  STDOUT", "AssistantNote")
          text:nl()

          for _, line in ipairs(vim.split(test.stdout, "\n")) do
            text:nl()
            text:append("  " .. line, "AssistantText")
          end
        end

        if test.stderr and test.stderr ~= "" then
          text:nl()
          text:append("  STDERR", "AssistantNote")
          text:nl()

          if test.stderr and test.stderr ~= "" then
            for _, line in ipairs(vim.split(test.stderr, "\n")) do
              text:nl()
              text:append("  " .. line, "AssistantText")
            end
          end
        end
      end
    end
  end

  return text
end

return AssisstantTransformer
