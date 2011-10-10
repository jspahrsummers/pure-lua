util = {}

-- Returns a copy of 't', but with the specified keys removed.
function util.table_copy_except (t, ...)
	local u = {}

	for k, v in pairs(t)
	do
		u[k] = v
	end

	for i, v in ipairs(arg)
	do
		u[v] = nil
	end

	return setmetatable(u, getmetatable(t))
end

-- Returns the keys and values of 't' as a string.
function util.table_tostring (t)
	local stringElements = {}

	for k, v in pairs(t)
	do
		local str = "[" .. tostring(k) .. "] = " .. tostring(v)
		table.insert(stringElements, str)
	end

	return "{ " .. table.concat(stringElements, ", ") .. " }"
end

-- Compares the keys and values of 'tableA' and 'tableB', returning whether they are equal.
function util.table_eq (tableA, tableB)
	for k, v in pairs(tableA)
	do
		if v ~= tableB[k] then return false end
	end

	for k, v in pairs(tableB)
	do
		if v ~= tableA[k] then return false end
	end

	return true
end

-- Returns 'key' from 'table', based on an equality comparison with the keys present.
function util.table_slow_index (table, key)
	for k, v in pairs(table)
	do
		if k == key then return v end
	end

	return nil
end

-- Compares the values of 'tableA' and 'tableB' in order, returning whether they are equal.
function util.itable_eq (tableA, tableB)
	for i, v in ipairs(tableA)
	do
		if v ~= tableB[i] then return false end
	end

	return true
end

-- Returns a deep copy of 'value'.
function util.deep_copy (value)
	if type(value) == "table" then
		local u = {}

		for k, v in pairs(value)
		do
			u[util.deep_copy(k)] = util.deep_copy(v)
		end

		local mt = util.deep_copy(getmetatable(value))
		return setmetatable(u, mt)
	elseif type(value) == "function" or type(value) == "thread" or type(value) == "userdata" then
		error("Values of type " .. type(value) .. " cannot be deep copied", 2)
	else
		return value
	end
end

-- Metatable for memoization
local memo_mt = {
	__mode = "v",
	__tostring = util.table_tostring,
	__index = util.table_slow_index
}

memo_mt.__metatable = memo_mt

-- Metatable for argument tables
local arg_mt = {
	__eq = util.itable_eq
}

arg_mt.__metatable = arg_mt

-- Returns a function which will call 'func' and memoize results, such that the same arguments will use cached results.
-- This implies that the return value of 'func' is identical given identical arguments.
-- If 'env' is provided, this is a function environment to use when executing 'func'.
function util.memoize (func, env)
	local memo = {}
	setmetatable(memo, memo_mt)

	if env then
		setfenv(func, env)
	end

	return function (...)
		local arg = { ... }
		setmetatable(arg, arg_mt)

		local result = memo[arg]

		if result == nil then
			result = { func(...) }
			memo[arg] = result
		end

		return unpack(result)
	end
end

-- A version of 'loadstring' that will memoize compiled strings,
-- such that compiling the same string on two different occasions results in the same function.
util.memoized_loadstring = util.memoize(loadstring)

