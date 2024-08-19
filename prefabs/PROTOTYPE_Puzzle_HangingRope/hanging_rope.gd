@tool
extends Node3D

class_name HangingRope;

var start_pos : Vector3;
var end_pos : Vector3;

@export
var follow_speed : float = 10;
@export
var start : Node3D;
@export
var end : Node3D;
@export
var segments : int = 5;

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

func position_segment (segment: Node3D, seg_start: Vector3, seg_end: Vector3) -> void:
	var dif = seg_end - seg_start;
	segment.scale = Vector3(1, 1, dif.length());
	segment.global_position = seg_start;
	if dif.length() > 0:
		segment.look_at(seg_end);

#func gen_positions (rope_start: Vector3, rope_end: Vector3):
#	for n in segments:
#		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _player:
		end_pos = _player._grapple_throw_position.global_position;
	else:
		if end:
			end_pos = end.global_position;
		if start:
			start_pos = start.global_position;
	global_position = start_pos;
	_smooth_pos = lerp(_smooth_pos, end_pos, follow_speed * delta);
	
	position_segment(_rope_segment, start_pos, _smooth_pos);
