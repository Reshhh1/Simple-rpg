local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local dataTemplate = {
	Version = 0.0069,

	Level = 1,
	Experience = 0,
	Currency = { Copper = 0, Silver = 0, Gold = 0 },

	Inventory = {},
	InventoryLimit = 15,
	Equipment = {
		["MainHand"] = {},
		["Helmet"] = {},
		["Chestplate"] =  {},
		["Leggings"] = {}
	}
}

local ProfileService = require(ServerScriptService.Core.Libs.ProfileService)
local ProfileStore = ProfileService.GetProfileStore("DEVELOPMENT", dataTemplate) -- DEVELOPMENT / RELEASE

local module = {}

module.Profiles = {}

function playerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId)
	print("Player_"..player.UserId)
	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		
		profile:ListenToRelease(function()
			module.Profiles[player] = nil
			
			player:Kick()
		end)
		
		if not player:IsDescendantOf(Players) then
			profile:Release()
		else
			module.Profiles[player] = profile
			print(module.Profiles[player].Data)
		end
	else
		player:Kick()
	end
end

function module:Init()
	for _, player in game.Players:GetPlayers() do
		task.spawn(playerAdded, player)
	end
	
	game.Players.PlayerAdded:Connect(playerAdded)
	game.Players.PlayerRemoving:Connect(function(player)
		if module.Profiles[player] then
			print(module.Profiles[player].Data)
			module.Profiles[player]:Release()
		end
	end)
end

function module:getProfileFromPlayer(player)
	while not module.Profiles[player] and player:IsDescendantOf(Players) do
		print("Loading")
		task.wait(0.1)
	end
	return module.Profiles[player]
end


return module
