local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataService = require(ServerScriptService.Core.Data.DataService)
local ItemService = require(ServerScriptService.Core.Services.ItemService)
local ValueObject = require(ReplicatedStorage.Core.Modules.ValueObject)

local Remotes = ReplicatedStorage.Remotes

local module = {}

function module.getItemsFromPlayer(player: Player)
	local items = {}
	local playerInventory = ServerStorage:WaitForChild("PlayersData"):FindFirstChild(player.Name):WaitForChild("Inventory")
	for _, item in pairs(playerInventory:GetChildren()) do
		local finalItem = module.itemToJSONFormat(item)
		table.insert(items, finalItem)
	end
	return items
end

function module.replicateInventory(player)
	local profile = DataService:getProfileFromPlayer(player)
	if not profile then return end
	
	local playerInventory = profile.Data.Inventory
	local inventoryServer = ServerStorage.PlayersData:FindFirstChild(player.Name):WaitForChild("Inventory")
	if inventoryServer then
		for _, item in pairs(playerInventory) do
			module.replicateItemToStorage(item, inventoryServer)
		end
	end
end

function module.replicateItemToStorage(item, parent)
	local itemFolder = Instance.new("Folder")
	for uuid, properties in pairs(item) do
		itemFolder.Name = uuid
		for itemName, properties in pairs(properties) do
			if itemName == "Rarity" then
				ValueObject.generateInstance("String", itemName, properties, itemFolder)
				continue
			end
			local itemNameInstance = ValueObject.generateInstance("String", "ItemName", itemName, itemFolder)
			
			for folderName, folderChildren in pairs(properties) do
				print(folderName)
					local folderInstance = Instance.new("Folder")
					folderInstance.Name = folderName
					folderInstance.Parent = itemNameInstance
					for attributeName, attributeValue in pairs(folderChildren) do
						if typeof(attributeValue) == "number" then
							ValueObject.generateInstance("Number", attributeName, attributeValue, folderInstance)
						end
					end
				
			end
		end
		itemFolder.Parent = parent
	end
end

--[[
	Moves the given item to the player's inventory
--]]
function module.moveToInventory(player, item, isSwapping)
	local playerInventory = ServerStorage.PlayersData:FindFirstChild(player.Name):WaitForChild("Inventory")
	local isExeedingLimit = module.isExeedingLimit(player)
	if playerInventory  then
		if not isExeedingLimit or isSwapping == true then
			print(item)
			item.Parent = playerInventory
		else
			print("EXEEDING LIMIT")
		end
	end
end

function module.isExeedingLimit(player)
	local Profile = DataService:getProfileFromPlayer(player)
	if not Profile then return end
	
	local playerItems = ServerStorage.PlayersData:FindFirstChild(player.Name):FindFirstChild("Inventory"):GetChildren()
	local inventoryLimit = Profile.Data.InventoryLimit
	local isExeeding = false
	if #playerItems >= inventoryLimit then
		isExeeding = true
	end
	return isExeeding
end

function module.doesPlayerOwnTool(player, tool)
	local playerInventory = ServerStorage.PlayersData:FindFirstChild(player.Name):FindFirstChild("Inventory")
	local ownsTool = false
	print(tool)
	if playerInventory:FindFirstChild(tool) then
		ownsTool = true
	end
	print(ownsTool)
	return ownsTool
end

function module.getItemFromPlayerStorage(player, itemName)
	local playerInventory = ServerStorage.PlayersData:FindFirstChild(player.Name):FindFirstChild("Inventory")
	local returnItem = playerInventory:FindFirstChild(itemName)
	return returnItem
end

function module.itemToJSONFormat(item)
	local itemName = item.Name
	local itemInstance = {}
	itemInstance[itemName] = {}
	local thisItem = itemInstance[itemName]
	for _, child in pairs(item:GetChildren()) do
		if child.Name ~= "Rarity" then
			thisItem[child.Value] = {}
			for _, folder in pairs(child:GetChildren()) do
				thisItem[child.Value][folder.Name] = {}
				for _, attribute in pairs(folder:GetChildren()) do
					thisItem[child.Value][folder.Name][attribute.Name] = {}
					thisItem[child.Value][folder.Name][attribute.Name] = attribute.Value
				end
			end
		else
			thisItem[child.Name] = child.Value
		end
	end
	return itemInstance
end

function module.saveInventoryData(player)
	local profile = DataService:getProfileFromPlayer(player)
	if not profile then return end
	
	local Inventory = {}
	local playerStorage = ServerStorage.PlayersData:FindFirstChild(player.Name):WaitForChild("Inventory")
	if playerStorage then
		for index, item in pairs(playerStorage:GetChildren()) do
			local isValid = ItemService.doesItemExists(item.ItemName.Value)
			if isValid == true then
				local jsonItem = module.itemToJSONFormat(item)
				table.insert(Inventory, jsonItem)
			end
		end
		
		--Instead of resetting revert old data instead
	else
		print(Inventory)
		Inventory = profile.Data.Inventory
	end	
	profile.Data.Inventory = Inventory
end

return module
