@tool
extends TextureRect

class_name Crosshair;

@export
var normal: Texture2D;
@export
var interact: Texture2D;
@export
var can_interact: bool = false;

func _process (delta: float) -> void:
	if can_interact:
		texture = interact;
	else:
		texture = normal;
