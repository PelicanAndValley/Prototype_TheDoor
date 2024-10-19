extends GPUParticles3D

class_name Effect;

@export
var sub_particles : GPUParticles3D;

func trigger () -> void:
	self.emitting = true;
	if sub_particles:
		sub_particles.emitting = true;
