extends Area3D;

class_name GrapplingHook;

@export
var vertical_rise : float = 20;
@export
var land_particle : PackedScene;
@export
var rope_climable : PackedScene;
@export
var hit_audio : AudioStreamPlayer3D;

var target : Grappleable;
var grappled : bool = false;
var thrown : bool = false;
var _end_pos : Vector3;
var _move_vector : Vector3;
var _original_pos : Vector3;
var _distance_travelled : float = 0;
var _vertical_offset : float = 0;
var _speed : float = 10;
var _model : Node3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_model = $GrapplingHookModel;

func _process(delta: float) -> void:
	# Moving through the air
	if thrown and !grappled:
		_distance_travelled += _speed * delta;
		if _distance_travelled >= _move_vector.length():
			_distance_travelled = _move_vector.length();
			grappled = true;
		var travelled_frac = _distance_travelled / _move_vector.length();
		_vertical_offset = sin(travelled_frac * PI) * vertical_rise * _move_vector.length();
		var total_movement = (_move_vector.normalized() * _distance_travelled) + (Vector3.UP * _vertical_offset) * delta;
		var new_pos = _original_pos + total_movement;
		look_at(position + (new_pos - global_position));
		global_position = new_pos;
	# Just landed
	elif grappled and thrown:
		thrown = false;
		global_position = _end_pos;
		# glint
		var particles : GPUParticles3D = land_particle.instantiate();
		add_child(particles);
		particles.emitting = true;
		# rope
		#var rope : Climbable = rope_climable.instantiate();
		#add_child(rope);
		#rope.raycast.add_exception(self);
		#rope.raycast.add_exception(target);
		

func on_hook_collided ():
	grappled = true;
	hit_audio.play();

func _physics_process(delta: float) -> void:
	pass;

func throw (og_pos : Vector3, grappleable: Grappleable, hit_pos: Vector3, speed : float = 10) -> void:
	target = grappleable;
	if grappleable.grapple_position:
		_end_pos = grappleable.grapple_position.global_position;
	else:
		_end_pos = hit_pos;
	grappleable.connect_hook(self);
	_original_pos = og_pos;
	_move_vector = _end_pos - _original_pos;
	_speed = speed;
	thrown = true;
	#apply_central_impulse(direction * speed);
