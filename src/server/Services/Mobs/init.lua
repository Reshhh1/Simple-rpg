local Players =  game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HitboxModule = require(ServerScriptService.Modules.HitboxModule)
local SoundModule = require(ReplicatedStorage.Modules.SoundModule)

local module = {}
module.__index = module
module.Models = game:GetService("ServerStorage"):WaitForChild("Mobs")


function module.new(mobName: string, cframe)
	local self = require(script[mobName]).new(cframe)
	setmetatable(self, module)
	self:initBuilder()	return self
end

function module:_findNearestPlayer()
	local playerList = Players:GetPlayers()
	local nearestPlayer = nil
	local distance = nil
	local direction = nil
	
	for _, player in pairs(playerList) do
		local character = player.Character
		if character then
			local humanoidrootpart = character:FindFirstChild("HumanoidRootPart")
			if humanoidrootpart then
				local distanceVector = humanoidrootpart.Position - self.Root.Position
				if not nearestPlayer and  distanceVector.Magnitude <= self.agroDistance then
					nearestPlayer = player
					distance = distanceVector.Magnitude
					direction = distanceVector.Unit
				elseif nearestPlayer and distanceVector.Magnitude < self.switchAgroDistance then
					nearestPlayer = player
					distance = distanceVector.Magnitude
					direction = distanceVector.Unit
				end	
			end
		end
	end

	return nearestPlayer, distance, direction
end

function module:_isInsideRadius ()
	if self.Humanoid and self.Humanoid.Health > 0 then
		local originVector = (self.Origin.Position - self.Root.Position)
		local distanceFromOrigin = originVector.Magnitude
		local originDirection = originVector.Unit
		return distanceFromOrigin, originDirection
	end
end

function module:initBuilder()
	self:initBillBoard()	
	self:initHumanoidProperties()
	self:initMobInfo()
end

function module:initBillBoard()
	local Background = self.BillBoard.Hpbar:WaitForChild("Background")
	Background.Text = tostring(self.Health).."/"..tostring(self.Health)
	local LevelTag = self.BillBoard:WaitForChild("Level")
	LevelTag.Text = "Lv. "..tostring(self.Level)
	local NameTag = self.BillBoard:WaitForChild("Name")
	NameTag.Text = self.Name
end

function module:initMobInfo()
	local infoFolder = self.Character:FindFirstChild("Info")
	
	infoFolder.Mobname.Value = self.Name
	infoFolder.Level.Value = self.Level
end

function module:initHumanoidProperties()
	self.Humanoid.WalkSpeed = self.walkSpeed
	self.Humanoid.Health = self.Health
	self.Humanoid.MaxHealth = self.Health
end
return module
