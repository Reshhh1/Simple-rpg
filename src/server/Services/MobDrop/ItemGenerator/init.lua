local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local InventoryService = require(ServerScriptService.Core.Data.InventoryService)

local module = {}


function module.new(player, Rarity, WeaponName)
	local uuid = createUUIDItem()
	local generateItem = require(script.Weapon).new(Rarity, WeaponName, uuid)
	if generateItem then
		InventoryService.moveToInventory(player, uuid)
	end
end

function module.newWeapon(player)
	local uuid = createUUIDItem()
	local weapon = require(script.Weapon).newWeapon("Rare",uuid)	
	if weapon then
		InventoryService.moveToInventory(player, uuid)
	end
end

function createUUIDItem()
	local uuid = generateUUID()
	local uuidInstance = Instance.new("Folder")
	uuidInstance.Name = uuid
	return uuidInstance
end

function generateUUID()
	local uuid = HttpService:GenerateGUID(false)
	return uuid
end
return module
