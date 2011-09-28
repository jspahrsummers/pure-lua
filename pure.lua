require('util')

pure = {}

-- Set up a metatable for the pure environment
local pure_mt = {}

-- Lock the pure environment's metatable
pure_mt.__metatable = pure_mt

-- A whitelist for 'string' functions available to pure functions
local string_whitelist = {
	["byte"] = string.byte,
	["char"] = string.char,
	["find"] = string.find,
	["format"] = string.format,
	["gmatch"] = string.gmatch,
	["gsub"] = string.gsub,
	["len"] = string.len,
	["lower"] = string.lower,
	["match"] = string.match,
	["rep"] = string.rep,
	["reverse"] = string.reverse,
	["sub"] = string.sub,
	["upper"] = string.upper
}

setmetatable(string_whitelist, pure_mt)

-- A whitelist for 'table' functions available to pure functions
local table_whitelist = {
	["insert"] = table.insert,
	["maxn"] = table.maxn,
	["remove"] = table.remove,
	["sort"] = table.sort
}

setmetatable(table_whitelist, pure_mt)

-- A whitelist for 'math' functions available to pure functions
local math_whitelist = {
	["abs"] = math.abs,
	["acos"] = math.acos,
	["asin"] = math.asin,
	["atan"] = math.atan,
	["atan2"] = math.atan2,
	["ceil"] = math.ceil,
	["cos"] = math.cos,
	["cosh"] = math.cosh,
	["deg"] = math.deg,
	["exp"] = math.exp,
	["floor"] = math.floor,
	["fmod"] = math.fmod,
	["frexp"] = math.frexp,
	["huge"] = math.huge,
	["ldexp"] = math.ldexp,
	["log"] = math.log,
	["log10"] = math.log10,
	["max"] = math.max,
	["min"] = math.min,
	["modf"] = math.modf,
	["pi"] = math.pi,
	["pow"] = math.pow,
	["rad"] = math.rad,
	["sin"] = math.sin,
	["sinh"] = math.sinh,
	["sqrt"] = math.sqrt,
	["tan"] = math.tan,
	["tanh"] = math.tanh
}

setmetatable(math_whitelist, pure_mt)

-- A whitelist for 'os' functions available to pure functions
local os_whitelist = {
	["difftime"] = os.difftime
}

setmetatable(os_whitelist, pure_mt)

-- A whitelist for global symbols available to pure functions
local pure_env = {
	["ipairs"] = ipairs,
	["next"] = next,
	["pairs"] = pairs,
	["select"] = select,
	["tonumber"] = tonumber,
	["tostring"] = tostring,
	["type"] = type,
	["unpack"] = unpack,
	["_VERSION"] = _VERSION,

	["math"] = math_whitelist,
	["os"] = os_whitelist,
	["string"] = string_whitelist,
	["table"] = table_whitelist,

	-- Should these really be available?
	["assert"] = assert,
	["error"] = error,
	["pcall"] = pcall,
	["xpcall"] = xpcall
}

setmetatable(pure_env, pure_mt)

-- The pure environment's global environment is itself
pure_env._G = pure_env

-- Whether the pure environment has been locked down.
-- This is set to 'true' when the first sandboxed function has been defined.
-- Before this point, the pure environment can be modified.
local pure_env_locked = false

-- Save global environment
local global_env = _G

-- Returns 'func' sandboxed to only have access to pure functions and constants
function pure.sandbox (func)
	if not pure_env_locked then
		-- Lock out modifications in the pure environment
		pure_mt.__newindex = function (table, key, value)
			error("Cannot set '" .. key .. "' in pure environment", 2)
		end

		pure_env_locked = true
	end
	
	return util.memoize(func, pure_env)
end

-- Defines 'func' as being an impure function, with access to all global definitions.
-- This can be used to escape a pure environment.
function pure.unsafe (func)
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

-- Imports 'symbol' into the pure environment as 'name'. This should only be used for functions that are truly pure. Anything else will produce undefined results when called from a pure function.
-- This function is only usable before the first pure function has been defined.
-- Returns the imported value.
function pure.import (name, symbol)
	if pure_env_locked then
		error("Cannot import '" .. name .. "' into the pure environment after a pure function has been defined", 2)
	end

	pure_env[name] = symbol
	return symbol
end

-- Retrieve the metatable for the global environment, or create one if none exists.
local global_mt = getmetatable(global_env)

if global_mt == nil then
	global_mt = {}
	setmetatable(global_env, global_mt)
end

-- Defines a constant.
function pure.define (key, value)
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
	error("'" .. key .. "' does not exist in pure environment", 2)
end

-- When trying to set a new definition globally, validate purity.
global_mt.__newindex = function (table, key, value)
	-- Functions are sandboxed to be pure.
	if type(value) == 'function' then
		rawset(pure_env, key, pure.sandbox(value))

	-- ... except for impure functions.
	elseif type(value) == 'table' and value._unsafe_function then
		rawset(table, key, value._func)

	-- Anything else is taken to be a primitive data type not subject to restrictions.
	else
		rawset(table, key, value)
	end
end

-- If lookup fails in global environment, check pure environment.
global_mt.__index = function (table, key)
	return rawget(pure_env, key)
end
