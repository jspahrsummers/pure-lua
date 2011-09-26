function pure (fnc)
	local whitelist = {}

	whitelist.math = math
	whitelist.string = string
	whitelist._G = whitelist

	setfenv(fnc, whitelist)
	fnc()
	return fnc
end

print('Hello')

pure_pi = pure(function ()
	return math.pi
end)

print(pure_pi())

pure(function ()
	print ('Hello')
end)
