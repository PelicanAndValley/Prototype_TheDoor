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
@export
var audio_start : AudioStreamPlayer3D;
@export
var audio_end : AudioStreamPlayer3D;

var _player : Player;
var _rope_segment: Node3D;
var _smooth_pos : Vector3;
@export
var _make_sound : bool = false;

func hold (player: Player):
	_player = player;
	_player._held_rope = self;

func drop (point: Node3D):
	_player._held_rope = null;
	_player = null;
	end = point;

func start_sound () -> void:
	_make_sound = true;
	audio_start.play();
	audio_end.play();

func stop_sound() -> void:
	_make_sound = false;

func on_sound_finish_start () -> void:
	if _make_sound:
		audio_start.play();

func on_sound_finish_end () -> void:
	if _make_sound:
		audio_end.play();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rope_segment = $RopeSegmentModel;
	if _make_sound:
		start_sound();

func position_segment (segment: Node3D, seg_start: Vector3, seg_end: Vector3) -> void:
	var dif = seg_end - seg_start;
	segment.scale = Vector3(1, 1, dif.length());
	segment.global_position = seg_start;
	if dif.length() > 0:
		segment.look_at(seg_end);

func gen_positions (rope_start: Vector3, rope_end: Vector3):
	var rope_top : Vector3;
	var rope_bottom : Vector3;
	if rope_start.y > rope_end.y:
		rope_top = rope_start;
		rope_bottom = rope_end;
	else:
		rope_top = rope_end;
		rope_bottom = rope_start;
	
	var total_dif = rope_top - rope_bottom;
	total_dif
	#for n in segments:
	#	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if _player:
		end_pos = _player._grapple_throw_position.global_position;
	else:
		if end:
			end_pos = end.global_position;
		else:
			end_pos = global_position + Vector3.FORWARD;
	if start:
		start_pos = start.global_position;
	global_position = start_pos;
	_smooth_pos = lerp(_smooth_pos, end_pos, follow_speed * delta);
	
	position_segment(_rope_segment, start_pos, _smooth_pos);
