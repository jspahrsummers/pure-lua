require('pure')

unsafely(function ()
	print('Hello')
end)

function pure_pi ()
	return math.pi
end

unsafely(function ()
	print(pure_pi())
end)

print_hello = unsafe(function ()
	print ('Hello')
end)

print_hello()

impure_failure = function ()
	print ('Hello')
end

impure_failure()
