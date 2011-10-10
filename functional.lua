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

-- Returns two tables: one composed of the pairs from 'table' that passed predicate 'func', and one composed of pairs that failed the predicate.
module.partition_pairs = function (table, func)
	local pass = {}
	local fail = {}

	for k, v in pairs(table)
	do
		if func(k, v) then
			pass[k] = v
		else
			fail[k] = v
		end
	end

	return pass, fail
end

-- Creates a table by combining the given lists of keys and values.
-- The key at each index in 'keys' is combined with the value at the same index in 'values'.
-- The two lists must have the same number of elements.
-- It is an error to have two identical keys, as doing so would result in an indeterminate result.
module.zip = function (keys, values)
	local table = {}
	local count = # keys
	
	if count ~= # values then
		error("The lists of keys and values provided to zip() must have the same number of elements", 2)
	end

	for i = 1, count
	do
		local key = keys[i]

		if table[key] ~= nil then
			error("Cannot have two identical keys in the list provided to zip()", 2)
		end

		table[key] = values[i]
	end

	return table
end

-- Returns a list of the keys of 'table', and a list of the values of 'table', respectively.
-- The order of the lists is undefined, except that the index of a given key matches the index of its associated value.
module.unzip = function (table)
	local keys = {}
	local values = {}

	for k, v in pairs(table)
	do
		keys.insert(k)
		values.insert(v)
	end

	return keys, values
end

-- Flattens all recursive lists within 'list' into a one-dimensional list.
module.flatten = function (list)
	local result = {}

	for i, v in ipairs(list)
	do
		if type(v) == "table" then
			local flattened = module.flatten(v)
			for fi, fv in ipairs(flattened)
			do
				table.insert(result, fv)
			end
		else
			table.insert(result, v)
		end
	end

	return result
end

-- Returns the first element from 'list', or nil if the list is empty.
module.head = function (list)
	if not list or # list == 0 then
		return nil
	else
		return list[1]
	end
end

-- Returns all but the first element from 'list'. If 'list' only contains one element, returns an empty list. If 'list' is empty, returns nil.
module.tail = function (list)
	local head, tail = module.decons(list)

	if head == nil then
		return nil
	else
		return tail
	end
end

-- Returns the head and the tail of 'list', or nil if the list is empty.
module.decons = function (list)
	if not list then
		return nil
	end

	local count = # list
	if count == 0 then
		return nil
	end

	local tail = {}
	for i = 2, count do
		tail[i - 1] = list[i]
	end

	return list[1], tail
end

-- Performs a left fold on the elements of 'list', passing 'value' and the first element into 'func'.
-- The result of 'func' is combined with the second element of 'list' into another call to 'func', and so forth, until the whole list has been reduced down to one element.
-- If 'list' is empty, 'value' is returned unmodified.
module.foldl = function (func, value, list)
	if not list or # list == 0 then
		return value
	end

	local head, tail = module.decons(list)
	return module.foldl(func, func(value, head), tail)
end

-- Performs a right fold on the elements of 'list', applying 'func' to each successive element of the list and the result of calling 'foldr' on the rest of the list.
-- The last element of the list is combined with 'value'.
-- If 'list' is empty, 'value' is returned unmodified.
module.foldr = function (func, value, list)
	if not list or # list == 0 then
		return value
	end

	local head, tail = module.decons(list)
	return func(head, module.foldr(func, value, tail))
end

-- Sandbox and export the functions in this module under a 'functional' namespace
functional = module.map_pairs(module, function (name, func)
	return name, pure.sandbox(func)
end)
