util = {}

-- Returns a copy of 't', but with the specified keys removed.
function util.table_copy_except (t, ...)
	local u = {}

	for k, v in pairs(t)
	do
		u[k] = v
	end

	for i, v in ipairs(arg)
	do
		u[v] = nil
	end

	return setmetatable(u, getmetatable(t))
end

-- Returns the keys and values of 't' as a string.
function util.table_tostring (t)
	local str = "{ "

	for k, v in pairs(t)
	do
		str = str .. tostring(k) .. " = " .. tostring(v) .. ", "
	end

	return str .. "}"
end

-- Compares the keys and values of 'tableA' and 'tableB', returning whether they were equal.
function util.table_eq (tableA, tableB)
	for k, v in pairs(tableA)
	do
		if v ~= tableB[k] then return false end
	end

	for k, v in pairs(tableB)
	do
		if v ~= tableA[k] then return false end
	end

	return true
end

-- Returns a deep copy of 'value'.
function util.deep_copy (value)
	if type(value) == "table" then
		local u = {}

		for k, v in pairs(value)
		do
			u[util.deep_copy(k)] = util.deep_copy(v)
		end

		local mt = util.deep_copy(getmetatable(value))
		return setmetatable(u, mt)
	elseif type(value) == "function" or type(value) == "thread" or type(value) == "userdata" then
		error("Values of type " .. type(value) .. " cannot be deep copied", 2)
	else
		return value
	end
end
