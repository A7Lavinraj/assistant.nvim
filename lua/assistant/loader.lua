local M = {}

function M.load(module_list)
  for _, module in ipairs(module_list) do
    require("assistant." .. module.name).load(module.opts)
  end
end

return M
