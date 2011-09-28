require('util')
require('match')
require('pure')
require('functional')

function fib (n)
	if n <= 1 then
		return 1
	else
		return fib(n - 1) + fib(n - 2)
	end
end

pure.define('pi', 3.14159)

function degToRad (n)
	return n * (pi / 180)
end

print_hello = pure.unsafe(function ()
	print('Hello')
end)

print_hello()
print(fib(40))
print(fib(80))
print(degToRad(180))

pass, fail = functional.partition({ 'a', 1, 'b', 2, 'c', 5 }, function (item)
	return type(item) == "number"
end)

print(util.table_tostring(pass))
print(util.table_tostring(fail))

print(util.table_tostring(functional.map({ 'a', 'b', 'c'}, function (str)
	return str .. 'bar'
end)))

print(util.table_tostring(functional.filter({ 'a', 'b', 'c'}, function (str)
	return (string.sub(str, 0, 1) == 'a')
end)))

local str = 'foobar'
local f = functional.curry(string.sub)
local bar = f(str)(4)

print(bar)

local g = functional.uncurry(f)
print(g(bar, 1, 2))

local h = match.define(
	{ 1 }, function () return 5 end,
	{ 2 }, function () return 11 end,
	{ any }, function (x) return x * 2 end,
	{ any, 5 }, function (x) return x / 2 end,
	{ any, any },
		function (x, y)
			return x * y
		end
)

print(h(1))
print(h(2))
print(h(3))
print(h(3, 5))
print(h(3, 6))

