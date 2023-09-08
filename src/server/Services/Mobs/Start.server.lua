local ServerScriptService = game:GetService("ServerScriptService")

local Mobs = require(ServerScriptService.Core.Services.Mobs)

local Spawners = game.Workspace.Spawners

function spawnMob(child)
	local mob  = Mobs.new(child.Parent.Name, child.CFrame)
	mob.Humanoid.Died:Connect(function()
		task.wait(15)
		spawnMob(child)
	end)
end

for _, child in pairs(Spawners:GetDescendants()) do
	if child.Parent:isA("Folder") and child.Parent.Name ~= "Spawners" then
		spawnMob(child)
	end
end