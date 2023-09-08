local module = {}

module.Rarity = {
	Common = {
		Hover = {
			Color = Color3.fromRGB(125, 125, 125)
		},
		Slot = {
			Backgroundcolor = Color3.fromRGB(108, 108, 108),
			StrokeColor = Color3.fromRGB(171, 171, 171)
		}
	},
	Uncommon = {
		Hover = {
			Color = Color3.fromRGB(53, 113, 56)
		},
		Slot = {
			Backgroundcolor = Color3.fromRGB(69, 104, 77),
			StrokeColor = Color3.fromRGB(107, 171, 77)
		}
	},
	Rare = {
		Hover = {
			Color = Color3.fromRGB(12, 138, 255)
		},
		Slot = {
			Backgroundcolor = Color3.fromRGB(94, 185, 255),
			StrokeColor = Color3.fromRGB(21, 139, 218)
		}
	},
	Epic = {
		Hover = {
			Color = Color3.fromRGB(118, 0, 126)
		},
		Slot = {
			Backgroundcolor = Color3.fromRGB(167, 49, 218),
			StrokeColor = Color3.fromRGB(174, 0, 218)
		}
	},
	Legendary = {
		Hover = {
			Color = Color3.fromRGB(221, 184, 0)
		},
		Slot = {
			Backgroundcolor = Color3.fromRGB(218, 202, 21),
			StrokeColor = Color3.fromRGB(255, 255, 0)
		}
	}
}
return module
