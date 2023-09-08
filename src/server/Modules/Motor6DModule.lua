local motor6d = {}

function motor6d.new(name ,part0, part1, C0)
	local doesExists = motor6d.doesExists(name, part0)
	checkAndDestroyWeld(part0)
	if not doesExists then
		motor6d.createMotor6D(name, part0, part1, C0)
	end
end

function motor6d.createMotor6D(name ,part0, part1, C0)
	local m6d = Instance.new("Motor6D")
	m6d.Name = name
	m6d.Part0 = part0
	m6d.Part1 = part1
	if C0 then
		m6d.C0 = CFrame.new(0,-1,0) * CFrame.Angles(math.rad(-90),0,0)
	end
	m6d.Parent = part0	
end

function motor6d.doesExists(name, basePart)
	local hasMotor6d = false
	if basePart:FindFirstChild(name) then 
		basePart:FindFirstChild("Handle").Name = name
		hasMotor6d = true 
	else  
		hasMotor6d = false
	end
	return hasMotor6d
end

function checkAndDestroyWeld(basePart)
	for _, child in pairs(basePart:getChildren()) do
		if child:isA("Weld") then
			child:Destroy()
		end
	end
end
return motor6d
