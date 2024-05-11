---@class AssistantState
---@field CWD? string
---@field FILETYPE? string
---@field FILENAME_WITH_EXTENSION? string
---@field FILENAME_WITHOUT_EXTENSION? string

---@class AssistantWindow
---@field buf? number
---@field win? number
---@field is_open? boolean
---@field height? number
---@field width? number
---@field augroup? number
---@field state? AssistantState

---@class AssistantRunner
---@field tests? Test[]
---@field command? { compile: { main: string, args: table<string> }, execute: { main: string, args: table<string> } }
---@field time_limit? number

---@class Test
---@field input string
---@field output string
---@field stdout string
---@field stderr string
---@field status string
---@field group string

---@class Renderer
---@field padding number
---@field bufnr number

---@class RendererOpts
---@field padding number
---@field bufnr number

---@class Button
---@field text string
---@field group string
---@field is_actice boolean

---@class ButtonSet
---@field gap number
---@field buttons Button[]

---@class Line
---@field content string
---@field group string

---@class Text
---@field lines Line[]
