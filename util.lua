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
