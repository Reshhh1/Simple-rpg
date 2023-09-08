local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Util.Loops)

local EquipmentService = require(ServerScriptService.Data.EquipmentService)

local module = {}

function module.new(player)
	local EquippedItemJSON = EquipmentService.equippedEquipmentToJSON(player, "MainHand")
	if EquippedItemJSON then
		local PrimaryStats = Util.findValueByKey(EquippedItemJSON, "Primary")
		local damage = math.random(PrimaryStats["MinDamage"], PrimaryStats["MaxDamage"])
		return damage
	end
end


return module
