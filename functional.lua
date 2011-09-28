functional = {}

-- Maps 'func' across 'lst', passing each element into 'func' (in order), and constructing a new list from the results.
function functional.map (lst, func)
	local result = {}

	for i, v in ipairs(lst)
	do
		result[i] = func(v)
	end

	return result
end

-- Maps 'func' across 'table', passing every key and value into 'func'.
-- 'func' should return a new key and a new value, which will be used to construct a new table from the results.
-- Because the same key may be returned multiple times, the resultant table may contain fewer elements than the input table.
function functional.map_pairs (table, func)
	local result = {}

	for k, v in pairs(lst)
	do
		newKey, newValue = func(k, v)
		result[newKey] = newValue
	end

	return result
end

-- Returns a list of the elements from 'lst' for which 'func' returns a true value.
function functional.filter (lst, func)
	local result = {}

	for i, v in ipairs(lst)
	do
		if func(v) then
			table.insert(result, v)
		end
	end

	return result
end

-- Returns a table of the key/value pairs from 'table' for which 'func' returns a true value.
function functional.filter_pairs (table, func)
	local result = {}

	for k, v in pairs(table)
	do
		if func(v) then
			result[k] = v
		end
	end

	return result
end
