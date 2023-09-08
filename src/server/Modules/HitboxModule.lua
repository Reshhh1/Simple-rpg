local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local hitbox = {}

function hitbox.new(
	size: Vector3,
	filter: {},
	root,
	cframe
)
	local self = setmetatable({},{__index = hitbox})
	self._size = size
	self._filter = filter
	self._root = root
	self._cframe = cframe
	return self
end

function getRaycastParams(self)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = self._filter
	return overlapParams
end

function createWeld(root, hitBox)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = hitBox
	weld.Parent = root	
end

function createHitbox(self)
	local HitBox = Instance.new("Part")
 
	HitBox.CFrame = self._cframe
	HitBox.BrickColor = BrickColor.new("Really red")
	HitBox.CanCollide = false
	HitBox.Size = self._size
	HitBox.Transparency = 1
	HitBox.Massless = true
	HitBox.Parent = workspace.misc
	createWeld(self._root, HitBox)
	return HitBox
end

function hitbox:getHitBox()
	return createHitbox(self)
end

function hitbox:getResults(hitbox)
	local overlapParams = getRaycastParams(self)
	return workspace:GetPartsInPart(hitbox, overlapParams)
end
return hitbox
