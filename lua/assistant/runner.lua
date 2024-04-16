local utils = require("assistant.utils")
local comparator = require("assistant.comparator")
local ui = require("assistant.ui")

local function runner()
	local filename = vim.fn.expand("%:p:r")
	local problem = io.open(filename .. ".prob", "r")

	if problem then
		local parsed_data = {}
		parsed_data = vim.json.decode(problem:read())
		local testcases = parsed_data.tests
		problem:close()

		local execute_command = {
			c = { "./a.out" },
			cpp = { "./a.out" },
			python = { "python3", filename .. ".py" },
			rust = { "./" .. filename },
		}

		local function callback()
			for _, testcase in pairs(testcases) do
				local job_id = vim.fn.jobstart(execute_command[vim.bo.filetype], {
					stdout_buffered = true,
					on_stdout = function(_, stdout)
						if comparator(table.concat(stdout, "\n"), testcase.output) then
							ui:render(nil, nil, "PASSED")
						else
							ui:render(testcase.output, table.concat(stdout, "\n"), "FAILED")
						end
					end,
				})

				vim.api.nvim_chan_send(job_id, testcase.input)
			end
		end

		utils.get_compiled(filename, callback)
	end
end

return runner
