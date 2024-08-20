extends AnimatableBody3D

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
var anchor : Anchor;
@export
var rope : HangingRope;

var _player : Player;
var _velocity : Vector3;
var _raycast : RayCast3D;

func _ready() -> void:
	_raycast = $RayCast3D;
	_raycast.add_exception(self);

func on_trigger_exit (body: Node3D) -> void:
	if body is Player:
		_player = null;

func on_trigger (body: Node3D) -> void:
	if body is Player:
		_player = body as Player;

func _physics_process(delta: float) -> void:
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
	
	translate(_velocity);
	key.translate(-_velocity);
	
	if _velocity.length() > 0.1 * delta and !anchor.audio.playing:
		anchor.audio.playing = true;
		#anchor.audio.volume_db = anchor.volume * _velocity.length();
	elif _velocity.length() <= 0.1 * delta and anchor.audio.playing:
		anchor.audio.playing = false;
