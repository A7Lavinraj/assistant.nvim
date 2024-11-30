---@class AssistantFloat
---@field win number?
---@field buf number?
---@field conf table
---@field bopts table?
---@field wopts table?
---@field enter boolean?

---@class AssistantFloat.opts
---@field conf table?
---@field bopts table?
---@field wopts table?
---@field enter boolean?

---@class AssistantText
---@field padding number
---@field lines {str:string,hl:string}[][]

---@class AssistantStore
---@field CWD string?
---@field FILETYPE string?
---@field FILENAME_WITHOUT_EXTENSION string?
---@field FILENAME_WITH_EXTENSION? string
---@field COMPILE_STATUS {code:nil,error:nil}?
---@field PROBLEM_DATA table?
---@field CHECKPOINTS table
---@field fetch function

---@class Command
---@field extension string?
---@field compile {main:string,args:table<string>}?
---@field execute {main:string,args:table<string>}?

---@class AssistantConfig
---@field commands Command[]
---@field time_limit number?
---@field border boolean?
---@field theme string?
