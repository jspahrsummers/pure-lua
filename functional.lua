require('pure')

local module = {}

-- Maps 'func' across 'lst', passing each element into 'func' (in order), and constructing a new list from the results.
module.map = function (lst, func)
	local result = {}

	for i, v in ipairs(lst)
	do
		result[i] = func(v)
	end

	return result
end

-- Maps 'func' across 'table', passing every key and value into 'func'.
-- 'func' should return a new key and a new value, which will be used to construct a new table from the results.
-- Because the same key may be returned multiple times, the resultant table may contain fewer elements than the input table.
module.map_pairs = function (table, func)
	local result = {}

	for k, v in pairs(table)
	do
		local newKey
		local newValue

		newKey, newValue = func(k, v)
		result[newKey] = newValue
	end

	return result
end

-- Returns a list of the elements from 'lst' for which 'func' returns a true value.
module.filter = function (lst, func)
	local result = {}

	for i, v in ipairs(lst)
	do
		if func(v) then
			table.insert(result, v)
		end
	end

	return result
end

-- Returns a table of the key/value pairs from 'table' for which 'func' returns a true value.
module.filter_pairs = function (table, func)
	local result = {}

	for k, v in pairs(table)
	do
		if func(v) then
			result[k] = v
		end
	end

	return result
end

-- Curries 'func', returning a function that takes the first argument to 'func', and which returns a function taking all the other arguments.
module.curry = function (func)
	return function (a)
		return function (...)
			return func(a, ...)
		end
	end
end

-- Binds the first arguments of 'func' to the given values. The first argument of 'bindr' is bound to the first argument of 'func', and so on.
module.bindl = function (func, ...)
	local args = { ... }

	return function (...)
		return func(unpack(args), ...)
	end
end

-- Binds the last arguments of 'func' to the given values. The last argument of 'bindr' is bound to the last argument to 'func', and so on.
module.bindr = function (func, ...)
	local args = { ... }

	return function (...)
		return func(..., unpack(args))
	end
end

-- For the given functor, returns a function which takes one more argument than 'func'.
-- The additional argument will be passed into the function returned by 'func', and the result of that call returned.
module.uncurry = function (func)
	return function(...)
		local args = { ... }

		local f = func(args[1])
		return f(unpack(args, 2))
	end
end

-- Returns two lists: one composed of the elements from 'lst' that passed predicate 'func', and one composed of elements that failed the predicate.
module.partition = function (lst, func)
	local pass = {}
	local fail = {}

	for i, v in ipairs(lst)
	do
		if func(v) then
			table.insert(pass, v)
		else
			table.insert(fail, v)
		end
	end

	return pass, fail
end

-- Sandbox and export the functions in this module under a 'functional' namespace
functional = module.map_pairs(module, function (name, func)
	return name, pure.sandbox(func)
end)
