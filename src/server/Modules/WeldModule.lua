local weld = {}

function weld.createWeld(part0, part1, parent)
	local weld = Instance.new("WeldConstraint")
	weld.Name = "AHH"
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = parent
end
return weld
