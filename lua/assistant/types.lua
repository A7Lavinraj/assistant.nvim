---@class AssistantWindowState
---@field is_open boolean
---@field buf number
---@field win number
---@field width_ratio number
---@field height_ratio number
---@field row "center" | "start" | "end" | nil
---@field col "center" | "start" | "end" | nil
---@field config table
---@field data table

---@class AssistantWindow
---@field state AssistantWindowState
---@field callback function(buf: number, win: number): void

---@class AssistantText
---@field padding number
---@field lines {str:string, hl:string}[][]

---@class AssistantPrompt
---@field buf number
---@field win number
---@field tcnumber number

---@class Command
---@field extension string
---@field compile {main:string, args:table<string>} | nil
---@field execute {main:string, args:table<string>} | nil

---@class AssistantConfig
---@field commands table<Command>
---@field time_limit number
---@field border string
---@field theme string

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
