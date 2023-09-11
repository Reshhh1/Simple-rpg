local Debris = game:GetService("Debris")

local module = {}

function module.new(id, name, parent)
	local Sound = module.createSoundInstance(id, name)
	Sound.Parent = parent
	Sound:Play()
	Sound.Ended:Connect(function()
		task.wait(1)
		Sound:Destroy()
	end)
end

function module.createSoundInstance(id, name)
	local Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://"..id
	Sound.RollOffMaxDistance = 50
	Sound.Name = name
	return Sound
end

return module
