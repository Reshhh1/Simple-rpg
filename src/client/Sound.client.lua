local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Remotes = ReplicatedStorage.Remotes

function init(name)
	if name then
		local soundId = getSoundId(name)
		local Sound = Instance.new("Sound")
		Sound.SoundId = soundId
		SoundService:PlayLocalSound(Sound)
		Sound.Ended:Wait()
		Sound:Destroy()
	end
end

function getSoundId(name)
	local soundId = SoundService:FindFirstChild(name).SoundId
	return soundId
end

Remotes.Client.playSound.OnClientEvent:Connect(function(name)
	init(name)
end)