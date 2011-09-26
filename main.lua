require('pure')

function fib (n)
	if n <= 1 then
		return 1
	else
		return fib(n - 1) + fib(n - 2)
	end
end

define('pi', 3.14159)

function degToRad (n)
	return n * (pi / 180)
end

print('Hello')
print(fib(4))
print(degToRad(180))
