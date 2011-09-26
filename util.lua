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
