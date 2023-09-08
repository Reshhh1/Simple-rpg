local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local module = {}

local TweenInfoObject = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0, true)

--[[
	Function to display damage indicators on the character
	@param damage(number): The amount of damage to display
	@param character(instance): The character to display the damage indicator to
	@param emitParticle(boolean): Wheneter or not a particle should be display on the humanoidrootpart
]]
function module.Show(damage, character, emitParticles)
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	local damageIndicator = script.DamageIndicator:Clone()
	damageIndicator.TextLabel.Text = tostring(damage)
	damageIndicator.Parent = HumanoidRootPart
	
	damageIndicator.Size = UDim2.new(0,0,0,0)
	damageIndicator.StudsOffsetWorldSpace = Vector3.new(math.random(-15,15) / 10, math.random(-15,15) / 10, math.random(-15,15) / 10)
	
	if emitParticles then
		spawnParticle(HumanoidRootPart)	
	end
	
	local tween = TweenService:Create(damageIndicator, TweenInfoObject, { Size = UDim2.new(2,0,2,0)})
	tween:Play()
	
	tween.Completed:Connect(function()
		damageIndicator:Destroy()
	end)
end

--[[
	Function to spawn particles on the parent
	@param parent(BasePart): The parent where the particles should be spawned on
]]
function spawnParticle(parent)
	local Particle = ServerStorage.VFX.Particles:WaitForChild("HitMarker"):Clone()
	Particle.Parent = parent
	Particle:Emit(1)
	Debris:AddItem(Particle, 1)
end
return module
