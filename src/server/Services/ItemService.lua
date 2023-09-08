local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ItemConfig = require(ReplicatedStorage.Data.Items)

local module = {}

local itemStoragePath = ServerStorage:WaitForChild("Items")

function module.doesItemExists(toolName)
	local doesExists = false
	if itemStoragePath:FindFirstChild(toolName) then
		doesExists = true
	end
	return doesExists
end

function module.getItem(toolName)
	local tool
	local doesExists = module.doesItemExists(toolName)
	if doesExists == true then
		tool = ServerStorage.Items:WaitForChild(toolName):Clone()
	end
	return tool
end

function module.getItemEquipType(toolname)
	local item = ItemConfig.Items[toolname]
	if item then
		return item.equipType 
	end
end
return module
