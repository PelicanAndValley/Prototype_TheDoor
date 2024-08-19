extends Interactable;

class_name Key;

@export
var balloon : Node3D;
@export
var balloon_rope : Node3D;
@export
var _rope_pos : Node3D;
@export
var anim_tree : AnimationTree;
@export
var sound : AudioStreamPlayer3D;

var _anim_playback : AnimationNodeStateMachinePlayback;
var _velocity : Vector3;

var has_balloon : bool = false;
var has_rope : bool = false;
var can_move : bool = false;
@export
var key_up_pos : Node3D;
@export
var speed : float;
@export
var acceleration : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim_playback = anim_tree["parameters/playback"];
	balloon.process_mode = Node.PROCESS_MODE_DISABLED;
	balloon.visible = false;
	balloon_rope.visible = false;

func dislodge () -> void:
	sound.play();
	_anim_playback.travel("Rise");
	has_balloon = true;
	balloon.process_mode = Node.PROCESS_MODE_INHERIT;
	balloon.visible = true;
	balloon_rope.visible = true;

func _physics_process(delta: float) -> void:
	pass;
