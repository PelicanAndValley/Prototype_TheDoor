extends Interactable;

class_name Key;

var _balloon_pos : Node3D;
var _rope_pos : Node3D;
var _anim_playback : AnimationNodeStateMachinePlayback;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_balloon_pos = $CollisionShape3D/BalloonPos;
	_rope_pos = $CollisionShape3D/RopePos;
	_anim_playback = $AnimationTree["parameters/playback"];

func dislodge () -> void:
	_anim_playback.travel("key_dislodge");
