extends Node3D

func ready () -> void:
	visible = false;

func reveal (player: Variant, point: Variant) -> void:
	visible = true;
