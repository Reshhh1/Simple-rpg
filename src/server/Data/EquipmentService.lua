local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local InventoryService = require(ServerScriptService.Data.InventoryService)
local DataService = require(ServerScriptService.Data.DataService)
local ItemService = require(ServerScriptService.Services.ItemService)

local Remotes = ReplicatedStorage.Remotes

local module = {}

function module.saveEquipmentData(player)
	local Profile = DataService:getProfileFromPlayer(player)
	if not Profile then return end
	local playerEquipmentStorage = ServerStorage.PlayersData:FindFirstChild(player.Name):WaitForChild("Equipment")
	
	local equipment = {}
	if playerEquipmentStorage then
		for _, equipmentSlot in pairs(playerEquipmentStorage:GetChildren()) do
			equipment[equipmentSlot.Name] = {}
			for _, equipmentItem in pairs(equipmentSlot:GetChildren()) do
				local isValid = ItemService.doesItemExists(equipmentItem.Name)
				if isValid == true then
					print(equipment)
					local jsonItem = InventoryService.itemToJSONFormat(equipmentItem)
					equipment[equipmentSlot.Name] = jsonItem
				end
			end
		end
	else
		equipment = Profile.Data.Equipment
	end
	Profile.Data.Equipment = equipment
end

function module.getEquipmentFromPlayer(player)
	local equipment = {}
	local playerEquipment = ServerStorage:WaitForChild("PlayersData"):FindFirstChild(player.Name):FindFirstChild("Equipment")
	
	for _, key in pairs(playerEquipment:GetChildren()) do
		equipment[key.Name] = {}
		for _, item in pairs(key:GetChildren()) do
			local finalItem = InventoryService.itemToJSONFormat(item)
			equipment[key.Name] = finalItem
			print(equipment)
		end
	end
	print(equipment)
	return equipment
end

function module.equippedEquipmentToJSON(player, equipType)
	local playerEquipment = ServerStorage:WaitForChild("PlayersData"):FindFirstChild(player.Name):FindFirstChild("Equipment")
	if playerEquipment then
		local equipmentTypeSlot = playerEquipment:FindFirstChild(equipType)
		for _, item in pairs(equipmentTypeSlot:GetChildren()) do
			return InventoryService.itemToJSONFormat(item)
		end
	end
end

function module.replicateEquipment(player)
	local profile = DataService:getProfileFromPlayer(player)
	if not profile then return end

	local playerEquipment = profile.Data.Equipment
	for key, item in pairs(playerEquipment) do
		local equipmentStorage = ServerStorage.PlayersData:FindFirstChild(player.Name):FindFirstChild("Equipment"):WaitForChild(key)
		if equipmentStorage and #item ~= 0 then
			print("Through")
			print(equipmentStorage)
			InventoryService.replicateItemToStorage(item, equipmentStorage)
		end
	end
end

function module.forceEquip(player, equipType)
	local profile = DataService:getProfileFromPlayer(player)
	if not profile then return end
	if equipType == "MainHand" then
		print("through")
		if profile.Data.Equipment.MainHand[1] then
			renderEquippedTool(player, profile.Data.Equipment.MainHand[1], equipType)
		end
	end
		
end

function meetsRequirementToEquip(player, toolName)
	local meetsRequirements = false
	local doesOwn = InventoryService.doesPlayerOwnTool(player, toolName)
	if doesOwn == true then
		meetsRequirements = true
	end
	return meetsRequirements
end

function hasSomethingEquiped(player, equipType)
	local slotReserved = false
	local equippedItem
	local playerEquipmentStorage = ServerStorage.PlayersData:FindFirstChild(player.Name):FindFirstChild("Equipment"):WaitForChild(equipType)
	if #playerEquipmentStorage:GetChildren() > 0 then
		slotReserved = true 
		equippedItem = playerEquipmentStorage:GetChildren()
	end
	
	return slotReserved, equippedItem
end

function clearBackPack(player: Player)
	local backpack = player.Backpack
	for _, tool in pairs(backpack:GetChildren()) do
		tool:Destroy()
	end
end

-- Removes all the welds of the players rightarm
function clearWeld(player)
	local Character = player.Character or player.CharacterAdded:Wait()
	local RightArm =  Character:FindFirstChild("Right Arm")
	
	if RightArm then
		for _, child in pairs(RightArm:GetChildren()) do
			if child:isA("Motor6D") then
				child:Destroy()
			end
		end
	end
end

function module.getPlayerToolNameFromUUID(player, uuid)
	local toolFromStorage = InventoryService.getItemFromPlayerStorage(player, uuid)
	local toolNameInstance = toolFromStorage:FindFirstChild("ItemName")
	if toolNameInstance then
		return toolNameInstance.Value
	end
end

function renderEquippedTool(player, toolName, equipType)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		local RenderTool = ItemService.getItem(toolName)
		if RenderTool then
			RenderTool.Parent = Character
			Humanoid:EquipTool(RenderTool)
		end
	end
end

-- Renders the tool
function renderTool(player,uuid, toolName, equipType)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		local toolFromStorage = InventoryService.getItemFromPlayerStorage(player, uuid)-- E
		toolFromStorage.Parent = ServerStorage.PlayersData:FindFirstChild(player.Name):WaitForChild("Equipment"):WaitForChild(equipType)

		local RenderTool = ItemService.getItem(toolName)
		if RenderTool then
			print(toolName)
			print("NEW TOOL RENDERD")
			RenderTool.Parent = Character
			Humanoid:EquipTool(RenderTool)
		end
	end
end

function equipTool(player, uuid)
	local meetsRequirements = meetsRequirementToEquip(player, uuid)
	if meetsRequirements == true then
		local Character = player.Character or player.CharacterAdded:Wait()
		local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")
		local toolName = module.getPlayerToolNameFromUUID(player, uuid)
		if toolName then
			local equipType = ItemService.getItemEquipType(toolName)
			local hasEquippedSomething, equippeditem = hasSomethingEquiped(player, equipType)
			if hasEquippedSomething then
				print("HAS SOMETHING EQUIPED")
				InventoryService.moveToInventory(player, equippeditem[1], true)
				Humanoid:UnequipTools()
				clearBackPack(player)
				clearWeld(player)
				task.wait()
				renderTool(player,uuid, toolName, equipType)
			else
				print("NEW EQUIPPED")
				clearBackPack(player)
				clearWeld(player)
				renderTool(player,uuid, toolName, equipType)
			end
		end
	end
end

function unequipTool(player, equipType)
	local hasSomethingEquiped, equippedItem = hasSomethingEquiped(player, equipType)
	if hasSomethingEquiped == true then
		print(equippedItem)
		InventoryService.moveToInventory(player, equippedItem[1])
		
		local Character = player.Character or player.CharacterAdded:Wait()
		local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			Humanoid:UnequipTools()
			clearBackPack(player)
			clearWeld(player)
		end
	end
end

Remotes.Server.EquipItem.OnServerEvent:Connect(equipTool)
Remotes.Server.UnequipItem.OnServerEvent:Connect(unequipTool)
return module
