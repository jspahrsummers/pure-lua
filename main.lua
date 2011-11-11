-{ extension('match') }

require('util')
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

local h = function (x)
	match x with
	| 1 -> return 5
	| 2 -> return 11
	| _ -> return x * 2
	end
end

print(h(1))
print(h(2))
print(h(3))

print(util.table_tostring(functional.flatten({ { 5 }, {{{{ "hello" }}}}, {{ "bar" }} })))

local tbl = { "foo", 2, 3, "bar", 5.5 }
print(tostring(functional.head(tbl)))
print(util.table_tostring(functional.tail(tbl)))

local numList = { 2, 3, 4 }
local sub = function (a, b)
	return a - b
end

print(tostring(functional.foldl(sub, 1, numList)))
print(tostring(functional.foldr(sub, 1, numList)))
