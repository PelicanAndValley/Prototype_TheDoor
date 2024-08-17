extends Node3D

class_name BigDoor;

var _anim_tree : AnimationTree;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim_tree = $AnimationTree;

func open_door() -> void:
	var playback : AnimationNodeStateMachinePlayback = _anim_tree["parameters/playback"];
	playback.travel("big_door_open");
