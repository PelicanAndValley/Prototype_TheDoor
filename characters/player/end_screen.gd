extends ColorRect

class_name EndScreen;

@export
var anim : AnimationTree;

func start () -> void:
	anim["parameters/playback"].travel("End_screen");
