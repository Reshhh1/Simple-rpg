local ServerScriptService = game:GetService("ServerScriptService")
local CollisionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local InventoryService = require(ServerScriptService.Data.InventoryService)
local ParticleModule = require(ReplicatedStorage.Modules.ParticleModule)
local ItemGenerator = require(ReplicatedStorage.Services.MobDrop.ItemGenerator)
local MobConfig = require(ServerScriptService.Services.DropConfig)
local WeldModule = require(ServerScriptService.Modules.WeldModule)
local itemReplicaStorage = ServerStorage.VFX.ItemReplica
local Remotes = ReplicatedStorage.Remotes

--COULD BE IMPROVED -> UNIQUE SOUNDS FOREACH RARITY
local DEFAULT_SOUND = SoundService:WaitForChild("ItemPickup")

local ChanceOfRarities = {
	Common = {1, 60},
	Uncommon = {61, 85},
	Rare = {86, 95},
	Epic = {96, 98},
	Legendary = {99, 100}
}

local module = {}
module.__index = module
module.chanceToDropItem = { 1, 1 }

function module.new(mobName, position)
	local self = setmetatable({}, module)
	self.Mob = MobConfig[mobName]
	self.Rarity = pickRandomRarity()
	self.Model = ServerStorage.VFX.itemDrops[self.Rarity].ItemDrop:Clone()
	self:raycastToGround(position)
	self.Weapon = self:replicateAndPickItem(self.Mob.Drops)
	Debris:AddItem(self.Model, 180)
	ParticleModule.fromPart(self.Model, self.Model.A1:FindFirstChild("ParticleEmitter"))
	
	local ProximityPrompt = self.Model.ProximityPrompt
	ProximityPrompt.Triggered:Connect(function(player)
		self:onTrigger(player)
	end)
	return self
end

function module:raycastToGround(origin)
	local param = RaycastParams.new()
	param.FilterType = Enum.RaycastFilterType.Exclude
	param.FilterDescendantsInstances = {self.Model}
	param.CollisionGroup = "Lootdrop"
	local result: RaycastResult = workspace:Raycast(origin, Vector3.new(0, -10, 0), param)
	if result.Instance then
		self.Model.Position = result.Position
	end
end

function module:onTrigger(player)
	local isAtLimit = InventoryService.isExeedingLimit(player)
	if not isAtLimit then
		self.Model:Destroy()
		self:Init(player)
	else
		Remotes.Client.NotEnoughSpace:FireClient(player)
		print('oeps te veel!')
	end
end

function module:Init(player)
	local soundName = DEFAULT_SOUND.Name
	Remotes.Client.playSound:FireClient(player, soundName)
	ItemGenerator.new(player, self.Rarity, self.Weapon)
end

function module:replicateAndPickItem(Drops)
	local weapon = pickRandomWeapon(Drops)
	self:replicateWeapon(weapon)
	return weapon
end

function module:replicateWeapon(weaponName)
	local WeaponReplica = itemReplicaStorage:FindFirstChild(weaponName)
	if WeaponReplica then
		local weapon = WeaponReplica:Clone()
		local weaponAttachment: Attachment = self.Model:FindFirstChild("ReplicaAttachment")
		weapon.Position = weaponAttachment.WorldPosition
		weapon.Anchored = true
		weapon.Parent = weaponAttachment
		local tweenInfo = TweenInfo.new(4.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)
		TweenService:Create(weapon, tweenInfo, { Orientation = weapon.Orientation + Vector3.new(0,360,0)}):Play()
	end
end

function module.isDroppingItem()
	local randomNumber = math.random(1, 1)
	local chance = module.chanceToDropItem
	local isDropping = false 
	if randomNumber >= chance[1] and randomNumber <= chance[2] then
		isDropping = true
	end
	return isDropping
end

function pickRandomRarity()
	local randomNumber = math.random(1, 100)
	local randomRarity
	for rarity, chance in pairs(ChanceOfRarities) do
		if randomNumber >= chance[1] and randomNumber <= chance[2] then
			randomRarity = rarity
		end
	end
	return randomRarity
end

function pickRandomWeapon(Drops)
	local randomNumber = math.random(1, #Drops.Weapons)
	return Drops.Weapons[randomNumber]
end

return module
