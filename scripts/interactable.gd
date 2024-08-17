extends PhysicsBody3D;

class_name Interactable;

signal on_interact;

func interact () -> void:
	if !on_interact.is_null():
		on_interact.emit();
