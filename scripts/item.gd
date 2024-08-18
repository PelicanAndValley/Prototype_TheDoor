extends Node3D;

class_name Item;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null) -> void:
	pass;

func _ready () -> void:
	change_visibility_layer_recursive(self);

func change_visibility_layer_recursive (parent: Node3D) -> void:
	if parent is VisualInstance3D:
		var vi = parent as VisualInstance3D;
		vi.layers = 0;
		vi.set_layer_mask_value(10, true);
	for child in parent.get_children():
		change_visibility_layer_recursive(child);
