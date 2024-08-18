@tool
extends Control

class_name Crosshair;

@export_group("Textures")
@export
var normal: Texture2D;
@export
var interact: Texture2D;
@export
var grapple: Texture2D;

var _tex : TextureRect;

@export_category("State")
enum State { Normal, Interact, Grapple };
@export
var state: State = State.Normal;

func _ready () -> void:
	_tex = $CrosshairTexture;

func _process (_delta: float) -> void:
	match state:
		State.Normal:
			_tex.texture = normal;
		State.Interact:
			_tex.texture = interact;
		State.Grapple:
			_tex.texture = grapple; 
