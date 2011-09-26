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

-- Returns 'func' sandboxed to only have access to pure standard library functions.
function pure (func)
	setfenv(func, pure_env)
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

-- Defines a constant.
define = function (key, value)
	rawset(pure_env, util.deep_copy(key), util.deep_copy(value))
end

-- Lock out modifications in the pure environment
pure_mt.__newindex = function (table, key, value)
	error("Cannot set variables in pure environment", 2)
end
