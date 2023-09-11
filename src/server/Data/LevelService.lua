local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local Remotes = ReplicatedStorage.Remotes

local LevelingConfig = require(ReplicatedStorage.Core.Data.LevelingConfig)
local SoundModule = require(ReplicatedStorage.Core.Modules.SoundModule)
local DataService = require(ServerScriptService.Core.Data.DataService)

local LEVELUP_SOUNDID = 5940919319
local module = {}

function module.checklevelup(player)
	local Profile = DataService:getProfileFromPlayer(player)
	if not Profile then return end

	local requiredExp = LevelingConfig.RequiredExperience(Profile.Data.Level)
	while (Profile.Data.Level + 1 <= LevelingConfig.MaxLevel) and Profile.Data.Experience >= requiredExp do
		Profile.Data.Experience -= requiredExp
		Profile.Data.Level += 1
		Remotes.Client.updateLevelDisplay:FireClient(player, Profile.Data.Level)
		requiredExp = LevelingConfig.RequiredExperience(Profile.Data.Level)
		onLevelUp(player)
	end

	if Profile.Data.Experience > LevelingConfig.MaxExperience and Profile.Data.Level == LevelingConfig.MaxLevel then
		Profile.Data.Experience = requiredExp
	end
	
	Remotes.Client.changeExpbar:FireClient(player, Profile.Data.Experience, requiredExp)
end

function onLevelUp(player)
	local Character = player.Character or player.CharacterAdded:Wait()
	SoundModule.new(LEVELUP_SOUNDID, "LevelUp", Character)
	
	local Particle = ServerStorage.VFX.Particles:WaitForChild("Levelup"):Clone()
	Particle.Parent = Character:WaitForChild("HumanoidRootPart")
	Particle:Emit(20)
	Debris:AddItem(Particle, 1)
	
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid.Health > 0 then
		Humanoid.Health = Humanoid.MaxHealth
	end
end

function module.getPlayerLevel(player)
	local Profile = DataService:getProfileFromPlayer(player)
	if not Profile then return end
	return Profile.Data.Level
end

Remotes.getPlayerLevelData.OnServerInvoke = module.getPlayerLevel
return module
