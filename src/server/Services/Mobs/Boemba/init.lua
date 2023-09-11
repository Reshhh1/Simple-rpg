local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AnimationModule = require(ReplicatedStorage.Core.Modules.AnimationModule)
local ParticleModule = require(ReplicatedStorage.Core.Modules.ParticleModule)
local HitboxModule = require(ServerScriptService.Core.Modules.HitboxModule)
local SoundModule = require(ReplicatedStorage.Core.Modules.SoundModule)
local MobConfig = require(ServerScriptService.Core.Data.MobConfig)
local Mobs = require(script.Parent)

local MobInfo = MobConfig[script.Name]

local module = {}
module.__index = module
setmetatable(module, Mobs)
module.Name = script.Name

function module.new(cframe)
	local self = {}
	setmetatable(self, module)
	
	self.Name = module.Name
	self.Origin = cframe
	
	--Base info
	self.baseHealth = 50
	self.baseDamage = 5
	self.minLevel = MobInfo.minLevel
	self.maxLevel = MobInfo.maxLevel
	self.walkSpeed = 10
	
	self.Level = math.random(self.minLevel, self.maxLevel)
	self.maxDamage = math.pow(self.baseDamage, self.Level * 0.1) + self.baseDamage
	self.minDamage = self.maxDamage * 0.9
	self.Health = self.baseDamage * (1 + (self.Level * 0.5))
		
	self.Character = Mobs.Models[module.Name]:Clone()
	self.Character:SetPrimaryPartCFrame(cframe)
	self.Root = self.Character.PrimaryPart
	self.Character.Parent = game.Workspace.misc
	
	self.BillBoard = self.Character:FindFirstChild("Head").BillboardGui
	self.Humanoid = self.Character:FindFirstChild("Humanoid")
	
	self.switchAgroDistance = 10
	self.agroDistance = 20
	self.stopDistance = 5
	self.maxDistance = 30
	
	self.attackDistance = 8
	self.lastAttack = os.clock()
	
	self.walkTrack = AnimationModule.getAnimationTrack(MobInfo.Animations.Walking, self.Character)
	
	self.Humanoid.Died:Connect(function()
		self.BillBoard:Destroy()
		local Particle = ServerStorage.VFX.Particles.MobKill:Clone()
		ParticleModule.new(Particle, 10, self.Root)
		SoundModule.new(MobInfo.Sounds.Death,"Death", Particle)
		Debris:AddItem(self.Character, 5)

		for _, BasePart in pairs(self.Character:GetChildren()) do
			if BasePart:IsA("BasePart") or BasePart:IsA("Decal") then
				local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				TweenService:Create(BasePart, tweenInfo, { Transparency = 1}):Play()
			end
		end
	end)
	
	self:init()
	
	return self
end

function module:init()
	coroutine.wrap(function()
		local isWalkingToSpawn = false
		while self.Character and self.Humanoid and self.Humanoid.Health > 0 do
			local distanceFromOrigin, originDirection = self:_isInsideRadius()
			local isNotinRadius = distanceFromOrigin > self.maxDistance
			
			if isWalkingToSpawn then
				if distanceFromOrigin < 10 then
					isWalkingToSpawn = false
					self.walkTrack:Stop()
				end
			end
			if isNotinRadius and not isWalkingToSpawn then
				isWalkingToSpawn = true
				self.Humanoid:MoveTo(Vector3.new(self.Origin.Position.X, 0, self.Origin.Position.Z))
			else
				local nearestPlayer, distance, direction = self:_findNearestPlayer()
				if nearestPlayer and not isWalkingToSpawn then
					if distance <= self.agroDistance and distance >= self.stopDistance then
						if not self.walkTrack.IsPlaying then
							self.walkTrack:Play()
						end
						self.Humanoid:Move(direction)
					else
						if self.walkTrack.IsPlaying then
							self.walkTrack:Stop()
						end
						self.Humanoid:Move(Vector3.new())
					end
					
					--attack
					if distance <= self.attackDistance and os.clock() - self.lastAttack >= 3.5 then
						self.lastAttack = os.clock()
						local playerCharacter = nearestPlayer.Character or nearestPlayer.CharacterAdded:Wait()
						self.Root.CFrame = CFrame.lookAt(self.Root.Position, Vector3.new(playerCharacter.PrimaryPart.Position.X, self.Root.Position.Y, playerCharacter.PrimaryPart.Position.Z))

						local AnimationTrack = AnimationModule.getAnimationTrack(MobInfo.Animations.Attack, self.Character)
						if AnimationTrack then
							AnimationTrack:Play()
							AnimationTrack:GetMarkerReachedSignal("Jump"):Once(function()
								SoundModule.new(MobInfo.Sounds.Jump,"Jump", self.Character)
							end)
							AnimationTrack:GetMarkerReachedSignal("damage"):Once(function()
								if self.Humanoid.Health > 0 then
									module._createHitbox(self)
								end
							end)
						end
					end
				end
			end
			task.wait(.1)
		end
	end)()
end

function module._createHitbox(self)
	local size = Vector3.new(3,5,6)
	local cframe = self.Root.CFrame * CFrame.new(0,0, -size.Z * 0.5)

	local Hitbox = HitboxModule.new(size,{ self.Character }, self.Root, cframe)
	local HitboxPart = Hitbox:getHitBox()

	local results = Hitbox:getResults(HitboxPart)
	game.Debris:AddItem(HitboxPart, 0.1)
	
	local hits = {}
	for _, child in pairs(results) do
		local enemyHumanoid = child.Parent:FindFirstChild("Humanoid")
		if enemyHumanoid and not table.find(hits, child.Parent) and Players:GetPlayerFromCharacter(child.Parent) then
			table.insert(hits, child.Parent)
			local damage = math.random(self.minDamage, self.maxDamage)
			SoundModule.new(MobInfo.Sounds.Hit, "Hit", child.Parent)
			enemyHumanoid:TakeDamage(damage)
		end
	end
end

return module
