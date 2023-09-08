local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage.Data.Items)
local ValueObject = require(ReplicatedStorage.Modules.ValueObject)

local module = {}

local BuffOfRarities = {
	Common = {0, 30},
	Uncommon = {30, 65},
	Rare = {65, 90},
	Epic = {90, 140},
	Legendary = {140, 200}
}

local primaryStats = {
	"MinDamage",
	"MaxDamage"
}

function module.new(Rarity, WeaponName, parent)
	local weaponStats = getStats(WeaponName, Rarity)
	local createdWeapon = createServerStorageItem(WeaponName,Rarity, weaponStats, parent)
	return createdWeapon
end

function module.newWeapon(rarity, parent)
	local weaponStats = getStats("Stonebane", "Rare")
	local weapon = createServerStorageItem("Stonebane", rarity, weaponStats, parent)
	return weapon
end

function createServerStorageItem(item, rarity, itemStats, parent)
	local weaponValue = ValueObject.generateInstance("String", "ItemName", item, parent)
	ValueObject.generateInstance("String", "Rarity", rarity, parent)
	local primaryStats = Instance.new("Folder")
	primaryStats.Name = "Primary"
	primaryStats.Parent = weaponValue
	for stat, value in pairs(itemStats) do
		local numberValue = ValueObject.generateInstance("Number", stat, value, primaryStats)
	end
	return weaponValue
end

function getStats(weapon, rarity)
	local currentStats = {}
	local weaponConfig = ItemConfig.Items[weapon]
	
	for i, stat in pairs(primaryStats) do
		local factor = ((getRandomNumber(BuffOfRarities[rarity][1], BuffOfRarities[rarity][2]) / 100) + 1)
		local calcStat = math.floor(weaponConfig[stat] * factor)
		currentStats[stat] = calcStat
	end
	return currentStats
end

function getRandomNumber(min, max)
	local randomNumber = math.random(min, max)
	return randomNumber 
end 

return module
