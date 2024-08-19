extends Node3D

class_name HangingRope;

var start_pos : Vector3;
var end_pos : Vector3;

@export
var follow_speed : float = 10;

var _player : Player;
var _rope_segment: Node3D;
var _smooth_pos : Vector3;

func hold (player: Player):
	_player = player;
	_player._held_rope = self;

func drop (point: Vector3):
	_player._held_rope = null;
	_player = null;
	end_pos = point;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rope_segment = $RopeSegmentModel;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _player:
		end_pos = _player._grapple_throw_position.global_position;
	global_position = start_pos;
	_smooth_pos = lerp(_smooth_pos, end_pos, follow_speed * delta);
	var dif = _smooth_pos - start_pos;
	_rope_segment.scale = Vector3(1, 1, dif.length());
	look_at(_smooth_pos);
