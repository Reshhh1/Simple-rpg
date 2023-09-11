local Debris = game:GetService("Debris")

local module = {}

module.DEFAULT_PARENT = workspace.misc

function module.new(Emitter: ParticleEmitter, emitAmount: number, Parent)
	Emitter.Parent = Parent
	Emitter:Emit(emitAmount)
	Debris:AddItem(Emitter, 1)
end

function module.fromPart(Part: Part, Emitter: ParticleEmitter, EmitAmount: number)
	Part.Parent =  module.DEFAULT_PARENT
	task.wait()
	Emitter:Emit(EmitAmount)
end

return module
