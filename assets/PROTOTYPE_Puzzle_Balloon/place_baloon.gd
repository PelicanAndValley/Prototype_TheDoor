extends Node3D

class_name PlaceBalloon;

var attach_pos : Node3D;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = attach_pos.global_position;
