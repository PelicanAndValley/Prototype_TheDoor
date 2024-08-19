extends Node3D

class_name PulleySystem;

var _key : Key;
var _platform : Platform;

var anchor_has_rope : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_key = $Key/Key;
	_platform = $Platform;

func _physics_process(delta: float) -> void:
	if _key.has_rope and _key.has_balloon and anchor_has_rope:
		_platform.can_move = true;
		_key.can_move = true;


func _on_anchor_on_interact(player: Variant, point: Variant) -> void:
	anchor_has_rope = true;
