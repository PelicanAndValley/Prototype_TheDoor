extends Node3D

class_name GrappleRope;

@export
var rope : Climbable;
@export
var rope_length : Node3D;
@export
var anim : AnimationTree;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rope.process_mode = Node.PROCESS_MODE_DISABLED;


func grow () -> void:
	rope_length.visible = true;
	var playback : AnimationNodeStateMachinePlayback = anim["parameters/playback"];
	playback.travel("rope_grow");
	
func anim_finish (name: StringName) -> void:
	rope.process_mode = Node.PROCESS_MODE_INHERIT;
