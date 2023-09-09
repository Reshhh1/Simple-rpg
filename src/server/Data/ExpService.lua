local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local DataService = require(ServerScriptService.Core.Data.DataService)
local LevelService = require(ServerScriptService.Core.Data.LevelService)
local LevelingConfig = require(ReplicatedStorage.Core.Data.LevelingConfig)

local module = {}

function module.GiveExperience(player: Player, Exp: number)
	local Profile = DataService:getProfileFromPlayer(player)
	
	if not Profile then return end

	Profile.Data.Experience += Exp
	LevelService.checklevelup(player)
end

function getPlayerExp(player)
	local Profile = DataService:getProfileFromPlayer(player)
	if not Profile then return end
	return Profile.Data.Experience
end

function getPlayerRequiredExp(player)
	local Profile = DataService:getProfileFromPlayer(player)
	if not Profile then return end
	return LevelingConfig.RequiredExperience(Profile.Data.Level)	
end

function getExperienceData(player)
	LevelService.checklevelup(player)
	local currentExp = getPlayerExp(player)
	local requiredExp = getPlayerRequiredExp(player)
	return currentExp, requiredExp or 0, 0
end

Remotes.getExperienceData.OnServerInvoke = getExperienceData
return module
