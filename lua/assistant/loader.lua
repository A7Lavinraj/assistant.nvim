local M = {}

M.module_list = {}

function M.add_list(list)
  M.module_list = list
end

function M.add(module)
  table.insert(M.module_list, module)
end

function M.load()
  for _, module in ipairs(M.module_list) do
    require("assistant." .. module.name).load(module.opt)
  end
end

return M
