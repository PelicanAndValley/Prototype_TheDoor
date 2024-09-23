extends GPUParticles3D

class_name StoryDirtExplosion;

@export
var sub_particles : GPUParticles3D;

func trigger () -> void:
	self.emitting = true;
	sub_particles.emitting = true;
