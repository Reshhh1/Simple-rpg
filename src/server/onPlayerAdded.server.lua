local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ServerScriptService = game:GetService("ServerScriptService")

local equipmentService = require(ServerScriptService.Data.EquipmentService)

local CollisionGroupPlayer = "Player"
PhysicsService:RegisterCollisionGroup(CollisionGroupPlayer)

Players.PlayerAdded:Connect(function(player)
	
	player.CharacterAdded:Connect(function(character)
		equipmentService.forceEquip(player, "MainHand")
		for _, object in pairs(character:GetDescendants()) do
			if object:isA("BasePart") then
				object.CollisionGroup = CollisionGroupPlayer
			end
		end
	end)
end)