local module = {}

function module.generateInstance(Type, name, value, parent)
	local dataInstance
	if Type == "String" then
		dataInstance = Instance.new("StringValue")
	elseif Type == "Boolean" then
		dataInstance = Instance.new("BoolValue")
	elseif Type == "Number" then
		dataInstance = Instance.new("NumberValue")
	
	end
	
	dataInstance.Name = name
	dataInstance.Value = value
	dataInstance.Parent = parent
	return dataInstance
end

return module
