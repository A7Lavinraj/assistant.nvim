---@class AssistantFloat
---@field win integer?
---@field buf integer?
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
---@field padding integer
---@field lines {str:string,hl:string}[][]

---@class Command
---@field extension string?
---@field compile {main:string,args:table<string>}?
---@field execute {main:string,args:table<string>}?

---@class AssistantConfig
---@field commands Command[]
---@field ui {icons:{success:string,failure:string,unknown:string,loading:table<string>}}
---@field core {process_budget:integer}
