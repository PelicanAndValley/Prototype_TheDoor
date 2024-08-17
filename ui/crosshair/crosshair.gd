@tool
extends TextureRect

class_name Crosshair;

@export_group("Textures")
@export
var normal: Texture2D;
@export
var interact: Texture2D;
@export
var grapple: Texture2D;

@export_category("State")
enum State { Normal, Interact, Grapple };
@export
var state: State = State.Normal;

func _process (delta: float) -> void:
	match state:
		State.Normal:
			texture = normal;
		State.Interact:
			texture = interact;
		State.Grapple:
			texture = grapple; 
