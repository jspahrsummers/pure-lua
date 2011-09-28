require('util')
require('functional')

match = {}
any = {}

function match.test (pattern, arg)
	if pattern == arg then
		return true
	elseif pattern == any then
		return true
	end

	return false
end

function match.define (...)
	local params
	local funcs

	funcs, params = functional.partition({ ... }, function (value)
		return type(value) == "function"
	end)

	if # params ~= # funcs then
		error("Number of parameter patterns should match number of functions", 2)
	end

	return function (...)
		local args = { ... }

		for i, param in ipairs(params)
		do
			if # param == # args then
				local matched = true
				local func = funcs[i]

				for i, pattern in ipairs(param)
				do
					if not match.test(pattern, args[i]) then
						matched = false
						break
					end
				end

				if matched then
					return func(...)
				end
			end
		end

		error("No match found for arguments: " .. util.table_tostring(args), 2)
	end
end
