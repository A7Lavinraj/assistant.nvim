---@class AssistantWindow
---@field win? number
---@field buf? number
---@field h_ratio number
---@field w_ratio number
---@field h_align "center"|"start"|"end"
---@field v_align "center"|"start"|"end"
---@field config table
---@field buf_opts? table
---@field win_opts? table
---@field enter boolean
---@field access boolean

---@class AssistantWindow.Opts
---@field config? table
---@field h_ratio number
---@field w_ratio number
---@field h_align "center"|"start"|"end"
---@field v_align "center"|"start"|"end"
---@field buf_opts? table
---@field win_opts? table
---@field enter boolean
---@field access boolean

---@class AssistantText
---@field padding number
---@field lines {str:string,hl:string}[][]

---@class AssistantStore
---@field CWD? string
---@field FILETYPE? string
---@field FILENAME_WITHOUT_EXTENSION? string
---@field FILENAME_WITH_EXTENSION? string
---@field COMPILE_STATUS? {code:nil,error:nil}
---@field PROBLEM_DATA? table
---@field init function

---@class Command
---@field extension? string
---@field compile? {main:string,args:table<string>}
---@field execute? {main:string,args:table<string>}

---@class AssistantConfig
---@field commands Command[]
---@field time_limit? number
---@field border? (string|string[])
---@field theme? string
