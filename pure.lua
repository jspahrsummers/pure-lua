require('util')

-- A whitelist for global symbols available to pure functions.
local pure_env = {}
pure_env.string = string
pure_env.util = util
pure_env._G = pure_env

-- Blacklist math.random() and math.randomseed() for pure functions.
pure_env.math = util.table_copy_except(math, 'random', 'randomseed')

-- Set up a metatable for the pure environment
local pure_mt = {}
setmetatable(pure_env, pure_mt)

-- Lock the pure environment's metatable
pure_mt.__metatable = pure_mt

-- Save global environment
local global_env = _G

-- Metatable for memoization
local memo_mt = {
	__mode = "v",
	__tostring = util.table_tostring,
	__index = util.table_slow_index
}

-- Metatable for argument tables
local arg_mt = {
	__eq = util.itable_eq
}

-- Returns 'func' sandboxed to only have access to pure standard library functions.
function pure (func)
	local memo = {}
	setmetatable(memo, memo_mt)

	setfenv(func, pure_env)
	return function (...)
		local arg = { ... }
		setmetatable(arg, arg_mt)

		local result = memo[arg]

		if result == nil then
			result = func(...)
			memo[arg] = result
		end

		return result
	end
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

-- Retrieve the metatable for the global environment, or create one if none exists.
local global_mt = getmetatable(global_env)

if global_mt == nil then
	global_mt = {}
	setmetatable(global_env, global_mt)
end

-- Defines a constant.
define = function (key, value)
	local deepKey = util.deep_copy(key)
	local existingValue = global_env.rawget(pure_env, deepKey)

	if existingValue then
		global_env.error("Constant '" .. key .. "' already defined as: " .. global_env.tostring(existingValue), 2)
	else
		global_env.rawset(pure_env, deepKey, util.deep_copy(value))
	end
end

-- Error out on lookups in the pure environment that have been blacklisted
pure_mt.__index = function (table, key)
	if table == pure_env then
		error("'" .. key .. "' does not exist in pure environment", 2)
	else
		return nil
	end
end

-- Lock out modifications in the pure environment
pure_mt.__newindex = function (table, key, value)
	error("Cannot set '" .. key .. "' in pure environment", 2)
end

-- When trying to set a new definition globally, validate purity.
global_mt.__newindex = function (table, key, value)
	-- Functions are sandboxed to be pure.
	if type(value) == 'function' then
		rawset(pure_env, key, pure(value))

	-- ... except for impure functions.
	elseif type(value) == 'table' and value._unsafe_function then
		rawset(table, key, value._func)

	-- Anything else is taken to be a primitive data type not subject to restrictions.
	else
		rawset(table, key, value)
	end
end

-- If lookup fails in global environment, check pure environment.
global_mt.__index = pure_env
