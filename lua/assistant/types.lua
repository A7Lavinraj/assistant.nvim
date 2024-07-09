---@class AssistantWindowState
---@field is_open boolean
---@field buf number
---@field win number

---@class AssistantWindow
---@field state AssistantWindowState

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
