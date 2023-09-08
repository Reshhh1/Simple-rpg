local Debris = game:GetService("Debris")

local module = {}

function module.playSoundInstance(soundInstance: Sound, parent)
	soundInstance.Parent = parent
	soundInstance:Play()
	soundInstance.Ended:Connect(function()
		Debris:AddItem(soundInstance, 1)
	end)
end

function module.createSoundInstance(id, name)
	local Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://"..id
	Sound.Name = name
	return Sound
end

return module
