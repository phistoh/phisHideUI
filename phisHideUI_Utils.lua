local addonName, phis = ...

-- copies the key-value pairs of table 'src' to table 'dst' (deep copy)
function phis.deep_copy(src, dst)
	for k,v in pairs(src) do
		-- if the table contains a table call the function recursively
		if type(v) == 'table' then
			dst[k] = {}
			dst[k] = deep_copy(v, dst[k])
		else
			dst[k] = v
		end
	end
	return dst
end

-- prints with the addon name as prefix
function phis.print(str)
	print('|cFFFF7D0A'..addonName..':|r '..str)
end