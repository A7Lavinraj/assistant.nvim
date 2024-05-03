---@class AssistantState
---@field buf number | nil
---@field win number | nil
---@field height number
---@field width number
---@field open boolean

---@class AssistantAPI
---@field CWD string?
---@field FILETYPE string?
---@field ABSOLUTE_FILENAME_WITHOUT_EXTENSION string?
---@field ABSOLUTE_FILENAME_WITH_EXTENSION string?
---@field RELATIVE_FILENAME_WITHOUT_EXTENSION string?
---@field RELATIVE_FILENAME_WITH_EXTENSION string?

---@class AssistantText
---@field content table<string>?

---@class AssistantRunner
---@field filepath string?
---@field command string?

---@class Button
---@field name string
---@field active boolean

---@class ButtonsConfig
---@field buttons Button[]
---@field gap number
---@field padding number
---@field buf number

---@class RadioButtons
---@field text string?
---@field gap number?
---@field padding number?
---@field buttons Button[]?
---@field init function?
---@field render function?
---@field highlights function?
---@field navigate function?
---@field buf number?
