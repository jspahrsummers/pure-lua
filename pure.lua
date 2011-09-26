function pure (fnc)
	local whitelist = {}

	whitelist.math = math
	whitelist.string = string
	whitelist._G = whitelist

	setfenv(fnc, whitelist)
	fnc()
	return fnc
end

global_meta = getmetatable(_G)

if global_meta == nil then
	global_meta = {}
	setmetatable(_G, global_meta)
end

global_meta.__newindex = function (table, key, value)
	if type(value) == 'function' then
		rawset(table, key, pure(value))
	else
		rawset(table, key, value)
	end
end

print('Hello')

function pure_pi ()
	return math.pi
end

print(pure_pi())

function print_hello ()
	print ('Hello')
end
