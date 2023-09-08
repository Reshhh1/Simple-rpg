local module = {}

module.Items = {
	["Stonebane"] = {
		equipType = "MainHand",
		MinDamage = 5,
		MaxDamage = 8,
		MaxCombo = 3,
		Cooldown = { 0.7, 0.7, 1.5 },
		Display = {
			displayIcon = "rbxassetid://14619015903",
			itemName = "Stonebane"
		}
	},
	["Cake"] = {
		equipType = "MainHand",
		displayIcon = "rbxassetid://7861843122"
	},
	["Water Bottle"] = {
		equipType = "MainHand",
		displayIcon = "rbxassetid://12935043943"
	},
	["Tool"] = {
		equipType = "Chestplate",
		displayIcon = "rbxassetid://14082155919"
	}
}

return module
