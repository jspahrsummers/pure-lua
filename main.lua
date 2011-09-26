dofile('pure.lua')

print('Hello')

function pure_pi ()
	return math.pi
end

print(pure_pi())

print_hello = unsafe(function ()
	print ('Hello')
end)

print_hello()
