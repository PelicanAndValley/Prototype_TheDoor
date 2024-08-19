extends Interactable;

class_name Key;

var _balloon_pos : Node3D;
var _rope_pos : Node3D;
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
	_balloon_pos = $BalloonPos;
	_rope_pos = $RopePos;
	_anim_playback = get_node("../AnimationTree")["parameters/playback"];

func dislodge () -> void:
	_anim_playback.travel("key_dislodge");

func _physics_process(delta: float) -> void:
	if can_move:
		print("MOVING");
		var target_velocity = Vector3.UP * speed * delta;
		var height_diff = key_up_pos.global_position.y - get_parent_node_3d().global_position.y;
		if height_diff < 1:
			target_velocity = Vector3.ZERO;
		print(height_diff);
		print(target_velocity);
		_velocity = lerp (_velocity, target_velocity, acceleration * delta);
		get_parent_node_3d().global_position += _velocity;
