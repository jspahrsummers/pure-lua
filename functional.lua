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
