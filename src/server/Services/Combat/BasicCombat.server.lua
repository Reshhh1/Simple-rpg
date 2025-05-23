---------------------------- Services -------------------------------
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local CalculateDamage = require(ServerScriptService.Core.Services.Combat.CalculateDamage)
local AnimationModule = require(ReplicatedStorage.Core.Modules.AnimationModule)
local DamageIndicator = require(ReplicatedStorage.Core.Modules.DamageIndicator)
local HitboxModule = require(ServerScriptService.Core.Modules.HitboxModule)
local M6DModule = require(ServerScriptService.Core.Modules.Motor6DModule)
local WeaponConfig = require(ReplicatedStorage.Core.Data.ItemData)
local SoundModule = require(ReplicatedStorage.Core.Modules.SoundModule)
local ExpService = require(ServerScriptService.Core.Data.ExpService)
local MobConfig = require(ServerScriptService.Core.Data.MobConfig)
local MobDrop = require(ServerScriptService.Core.Services.MobDrop)

local Remotes = ReplicatedStorage.Remotes
local Debounces = {}
local Combos = {}
local Size = Vector3.new(6,8,6)

--[[
	Function checks if the character has a tool and returns that
	@param character(Instance): The character thats being checked through
]]
function getTool(character)
	for _,child in pairs(character:GetChildren()) do
		if child:isA("Tool") then
			return child
		end
	end
end

function giveExp(player, mobCharacter)
	local enemyConfig = MobConfig[mobCharacter.Name]
	local mobInfo = mobCharacter:FindFirstChild("Info")
	if enemyConfig and mobInfo then
		local currentMobLevel = mobInfo:FindFirstChild("Level")
		local minAndMaxDifference = enemyConfig.maxLevel - enemyConfig.minLevel
		local differenceBetweenMaxLevel = enemyConfig.maxLevel - currentMobLevel.Value
		local factor = differenceBetweenMaxLevel / minAndMaxDifference
		local totalExpGain = math.round(((factor / 4) + 1) * enemyConfig.Exp)
		ExpService.GiveExperience(player, totalExpGain)
	end
end

Remotes.Server.M1Event.OnServerEvent:Connect(function(player)
	if not Debounces[player] then Debounces[player] = false end

	local Character = player.Character or player.CharacterAdded:Wait()
	local tool = getTool(Character)
	
	if not Debounces[player] and tool then
		Debounces[player] = true
		local ToolConfig = WeaponConfig.Items[tool.Name]
		if not Combos[player] then Combos[player] = 0 end
		Combos[player] = (Combos[player] % ToolConfig.MaxCombo) + 1
		
		SoundModule.new(ToolConfig.Sounds.swing,"Swing", Character)
		
		local Animation = AnimationModule.new(ToolConfig.Animations.attack, Character)
		
		if Animation.AnimationTrack and ToolConfig then
			Animation.AnimationTrack:Play()

			M6DModule.new("Handle",Character:WaitForChild("Right Arm"),tool:WaitForChild("Handle"),Character:WaitForChild("Right Arm"))
			Animation.AnimationTrack:GetMarkerReachedSignal("damage"):Once(function()
				CalculateDamage.new(player)
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
				local cframe = HumanoidRootPart.CFrame * CFrame.new(0,0, -Size.Z * 0.3)
				local hitbox = HitboxModule.new(Size, { Character }, HumanoidRootPart, cframe)
				local hitboxPart = hitbox:getHitBox()
				Debris:AddItem(hitboxPart, 0.1)
				
				local damage = CalculateDamage.new(player)
				local results = hitbox:getResults(hitboxPart)
				local hits = {}

				for _, child in pairs(results) do
					local enemyHumanoid = child.Parent:FindFirstChild("Humanoid")
					if enemyHumanoid
					and not table.find(hits, child.Parent)
					and enemyHumanoid.Health > 0
					and not Players:GetPlayerFromCharacter(child.Parent) then
						table.insert(hits, child.Parent)
						local enemyCharacter = child.Parent
						SoundModule.new(ToolConfig.Sounds.hit,"Hit", Character)
						enemyHumanoid:TakeDamage(damage)
						DamageIndicator.Show(damage, enemyCharacter, true)
						if enemyHumanoid.Health <= 0 then
							giveExp(player, enemyCharacter)
							local isDropingItem = MobDrop.isDroppingItem()
							if isDropingItem == true then
								MobDrop.new(enemyCharacter.Name, enemyCharacter:FindFirstChild("HumanoidRootPart").Position)	
							end
						end
					end
				end
			end)
		end
		task.wait(ToolConfig.Cooldown[Combos[player]])
		Debounces[player] = false
	end
end)