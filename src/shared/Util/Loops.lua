local module = {}

function module.findValueByKey(Table, targetKeys)
	local result
	for key, value in pairs(Table) do
		if key == targetKeys then
			return value
		elseif type(value) == "table" then
			local result = module.findValueByKey(value, targetKeys)
			if result then
				return result
			end
		end
	end
end

return module
