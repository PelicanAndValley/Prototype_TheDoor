extends Node3D;

class_name AnimationTrigger;

signal on_end;

@export
var animation_tree : AnimationTree;
@export
var animation : StringName;

func trigger () -> void:
	var playback = animation_tree["parameters/playback"];
	playback.travel(animation);

func animation_finished (anim_name: StringName) -> void:
	if anim_name == animation:
		on_end.emit();
