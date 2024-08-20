extends Node3D

class_name Door;

var _opened : bool = false;

@export
var anim : AnimationTree;

func open (player: Player) -> void:
	if !_opened:
		_opened = true;
		anim["parameters/playback"].travel("DoorOpen");
