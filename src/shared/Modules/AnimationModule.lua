local AnimationModule = {}

function AnimationModule.new(animationId, character): AnimationTrack
	local self = setmetatable({}, {__index = AnimationModule })
	self.character = character
	self.AnimationTrack = AnimationModule.getAnimationTrack(animationId, character)
	return self
end

function AnimationModule:remainPosition(eventMarker)
	self.AnimationTrack:GetMarkerReachedSignal(eventMarker):Connect(function()	
		self.AnimationTrack:AdjustSpeed(0)
	end)
	
end

function AnimationModule.getAnimationTrack(animationId, character) : AnimationTrack
	if character then
		local humanoid = character:WaitForChild("Humanoid")
		local animation = createAnimation(animationId)
		if humanoid.Health > 0 then
			local Animator = humanoid:WaitForChild("Animator")
			return Animator:LoadAnimation(animation)
		end
	end
end

function createAnimation(animationId) : Animation
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://".. tostring(animationId)
	return animation
end

return AnimationModule
