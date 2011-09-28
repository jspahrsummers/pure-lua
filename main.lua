require('pure')
require('functional')
require('util')

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
print(fib(40))
print(fib(80))
print(degToRad(180))

print(util.table_tostring(functional.map({ 'a', 'b', 'c'}, function (str)
	return str .. 'bar'
end)))

print(util.table_tostring(functional.filter({ 'a', 'b', 'c'}, function (str)
	return (string.sub(str, 0, 1) == 'a')
end)))
