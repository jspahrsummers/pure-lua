-- Returns 'func' sandboxed to only have access to pure standard library functions.
function pure (func)
	local whitelist = {}

	whitelist.math = math
	whitelist.string = string
	whitelist._G = whitelist

	setfenv(func, whitelist)
	return func
end

-- Defines 'func' as being an impure function, with access to all global definitions.
-- This can be used to escape a pure environment.
function unsafe (func)
	local mt = {
		__call = func
	}

	local table = {
		_unsafe_function = true,
		_func = func
	}

	setmetatable(table, mt)
	return table
end

do
	-- Retrieve the metatable for the global environment, or create one if none exists.
	local global_mt = getmetatable(_G)

	if global_mt == nil then
		global_mt = {}
		setmetatable(_G, global_mt)
	end

	-- When trying to set a new definition globally, validate purity.
	global_mt.__newindex = function (table, key, value)
		-- Functions are sandboxed to be pure.
		if type(value) == 'function' then
			rawset(table, key, pure(value))

		-- ... except for impure functions.
		elseif type(value) == 'table' and value._unsafe_function then
			rawset(table, key, value._func)

		-- Anything else is taken to be a primitive data type not subject to restrictions.
		else
			rawset(table, key, value)
		end
	end
end
