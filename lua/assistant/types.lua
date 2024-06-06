---@class AssistantState
---@field CWD string
---@field tab number
---@field FILETYPE string
---@field FILENAME_WITH_EXTENSION string
---@field FILENAME_WITHOUT_EXTENSION string

---@class AssistantWindow
---@field buf number
---@field win number
---@field is_open boolean
---@field augroup number
---@field opts table
---@field state AssistantState
---@field renderer AssistantRenderer
---@field runner AssistantRunner
---@field buttonset ButtonSet

---@class AssistantRenderer
---@field buf number
---@field padding number

---@class Test
---@field input string
---@field output string
---@field stdout string
---@field stderr string
---@field status string
---@field group string
---@field start_at number
---@field end_at number
---@field expand boolean

---@class AssistantRunner
---@field tests Test[]
---@field command {compile:{main:string, args:table<string>}, execute:{main:string, args:table<string>}}
---@field time_limit number
---@field cmp_cb function
---@field exe_cb function

---@class ButtonSet
---@field gap number
---@field buttons {text:string, group:string, is_active:boolean}[]

---@class Line
---@field content string
---@field hl {group:string, col_start:number, col_end:number}[]

---@class Text
---@field lines Line[]
