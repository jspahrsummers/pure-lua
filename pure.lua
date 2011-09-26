-- A whitelist for global symbols available to pure functions.
purity_whitelist = {}
purity_whitelist.string = string
purity_whitelist.purity_whitelist = purity_whitelist
purity_whitelist._G = purity_whitelist

do
	-- Returns a copy of 't', but with the specified keys removed.
	local table_copy_except = function (t, ...)
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

	-- Blacklist math.random() and math.randomseed() for pure functions.
	purity_whitelist.math = table_copy_except(math, 'random', 'randomseed')
end

-- Returns 'func' sandboxed to only have access to pure standard library functions.
function pure (func)
	setfenv(func, purity_whitelist)
	return func
end

-- Save the existing (impure) environment to use with unsafe functions.
local _existing_env = _G

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
	setfenv(func, _existing_env)
	return table
end

-- Immediately executes 'func' as an impure function.
function unsafely (func)
	return unsafe(func)()
end

purity_whitelist.pure = pure
purity_whitelist.unsafe = unsafe
purity_whitelist.unsafely = unsafely

do
	-- Retrieve the metatable for the global environment, or create one if none exists.
	local global_mt = getmetatable(_G)

	if global_mt == nil then
		global_mt = {}
		setmetatable(_G, global_mt)
	end

	-- Use this metatable for the whitelist environment too.
	setmetatable(purity_whitelist, global_mt)

	global_mt.__index = function(table, key)
		if table ~= purity_whitelist then
			return purity_whitelist[key]
		else
			return nil
		end
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
