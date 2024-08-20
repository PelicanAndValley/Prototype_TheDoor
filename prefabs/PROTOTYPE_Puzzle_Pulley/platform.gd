extends Node3D

class_name Platform;

@export
var speed : float = 1;
@export
var acceleration : float = 3;
@export
var can_move : bool = false;
@export
var key : Node3D;
@export
var key_key : Key;
@export
var anchor : Anchor;
@export
var collision : CollisionObject3D;
@export
var key_rise_speed_mult : float = 0.5;
@export
var key_top_level : Node3D;
@export
var position_speed : float = 10;

var _player : Player;
var _velocity : Vector3;
var _raycast : RayCast3D;
var _positioning_key : bool = false;

func _ready() -> void:
	_raycast = $RayCast3D;
	_raycast.add_exception(collision);

func on_trigger_exit (body: Node3D) -> void:
	if body is Player:
		_player = null;

func on_trigger (body: Node3D) -> void:
	if body is Player:
		_player = body as Player;

func _physics_process(delta: float) -> void:
	
	if !_positioning_key:
		
		var target_velocity = Vector3.ZERO;
		if _player:
			target_velocity = Vector3.DOWN * speed * delta;
		else:
			target_velocity = Vector3.ZERO;
		
		if !can_move:
			target_velocity = Vector3.ZERO;
		
		_velocity = lerp(_velocity, target_velocity, acceleration * delta);
		
		if _raycast.is_colliding():
			_velocity = Vector3.ZERO;
			_positioning_key = true;
		
		translate(_velocity);
		key.translate(-_velocity * key_rise_speed_mult);
		
		anchor.anim_tree["parameters/TimeScale/scale"] = _velocity.length() * anchor.speed;
		
		if _velocity.length() > 0.1 * delta and !anchor.audio.playing:
			anchor.audio.playing = true;
			#anchor.audio.volume_db = anchor.volume * _velocity.length();
		elif _velocity.length() <= 0.1 * delta and anchor.audio.playing:
			anchor.audio.playing = false;
	
	else:
		key.global_position = lerp(key.global_position, key_top_level.global_position, position_speed * delta);
		key_key._in_place = true;
