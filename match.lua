require('util')
require('functional')

match = {}

-- Represents a wildcard in a pattern matching definition
any = {}

-- Returns whether 'arg' satisfies 'pattern'.
local function test (pattern, arg)
	if pattern == arg then
		return true
	elseif pattern == any then
		return true
	end

	return false
end

-- Defines a pattern-matching function.
-- The first argument to this function must be a table representing an argument list to match against. Arguments can be patterns such as 'any', or literal values.
-- The second argument to this function must be a function to execute if the associated pattern matches. It can take as many arguments as the pattern matches against.
-- There can be any even number of successive arguments after the aforementioned, as long as they follow the pattern of "pattern, function."
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
					if not test(pattern, args[i]) then
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
