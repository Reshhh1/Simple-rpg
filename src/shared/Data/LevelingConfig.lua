local module = {}

module.MaxLevel = 100
module.RequiredExperience = function(Level)
	local rawExp = 50 + math.floor(math.pow( (Level - 1) * 10, 1.1 ))
	return  rawExp
end
module.MaxExperience = module.RequiredExperience(module.MaxLevel)

return module
