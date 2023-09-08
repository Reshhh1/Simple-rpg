local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.Core.Data.DataService)
local inventoryService = require(ServerScriptService.Core.Data.InventoryService)
local equipmentService = require(ServerScriptService.Core.Data.EquipmentService)

local ItemGenerator = require(ReplicatedStorage.Core.Services.MobDrop.ItemGenerator)
local playerStorages = ServerStorage.PlayersData
local Remotes = ReplicatedStorage.Remotes

DataService:Init()

function playerAdded(player)
	if not playerStorages:FindFirstChild(player.Name) then
		local playerFolder = Instance.new("Folder")
		playerFolder.Name = player.Name
		playerFolder.Parent = playerStorages
		
		local inventoryFolder = Instance.new("Folder")
		inventoryFolder.Name = "Inventory"
		inventoryFolder.Parent = playerFolder
		
		local equipmentFolder = Instance.new("Folder")
		equipmentFolder.Name = "Equipment"
		equipmentFolder.Parent = playerFolder
		
		local equipments = { "MainHand", "Helmet", "Chestplate", "Leggings" }
		for _, key in pairs(equipments) do
			local Folder = Instance.new("Folder")
			Folder.Name = key
			Folder.Parent = equipmentFolder
			
			Folder.ChildAdded:Connect(function()
				Remotes.Client.updateInventory:FireClient(player)
			end)
			Folder.ChildRemoved:Connect(function()
				Remotes.Client.updateInventory:FireClient(player)
			end)
		end
		
		inventoryFolder.ChildAdded:Connect(function(child)
			Remotes.Client.updateInventory:FireClient(player)
		end)
		inventoryFolder.ChildRemoved:Connect(function(child)
			Remotes.Client.updateInventory:FireClient(player)
		end)
	end
	inventoryService.replicateInventory(player)
	equipmentService.replicateEquipment(player)
	ItemGenerator.newWeapon(player)
end

for _, player in pairs(Players:GetPlayers()) do
	task.spawn(playerAdded, player)
end

Players.PlayerAdded:Connect(function(player)
	playerAdded(player)
end)
Players.PlayerRemoving:Connect(function(player)
	equipmentService.saveEquipmentData(player)
	inventoryService.saveInventoryData(player)
	local playerInventory = playerStorages:FindFirstChild(player.Name)
	if playerInventory then
		playerInventory:Destroy()
	end
end)

function getInventoryData(player)
	local inventory = inventoryService.getItemsFromPlayer(player)
	local equipment = equipmentService.getEquipmentFromPlayer(player)
	return inventory, equipment
end

Remotes.getInventoryData.OnServerInvoke = getInventoryData