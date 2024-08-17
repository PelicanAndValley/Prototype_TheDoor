extends CharacterBody3D

class_name Player;

@export_group("Movement")
@export
var walk_speed : float = 10;
@export
var run_speed : float = 30;
@export
var acceleration : float = 10;
@export
var jump_strength : float = 5;
@export_group("Climbing")
@export
var climb_speed : float = 30;
@export
var hop_time : float = 0.5;
@export_group("Camera")
@export
var look_speed : float = 0.001;
@export_group("Tools")
@export
var grappling_hook : PackedScene;
@export
var grapple_throw_strength : float = 20;

enum MoveState { WALKING, CLIMBING, CONTROLLED };
var move_state = MoveState.WALKING;

var _h_speed : float = 0;
var _cur_direction : Vector2 = Vector2.DOWN;
var _v_speed : float = 0;
var _mouse_captured = false;
var _look_direction : Vector2 = Vector2.ZERO;
var _camera : Camera3D;
var _interact_raycast : RayCast3D;
var _grapple_raycast : RayCast3D;
var _crosshair : Crosshair;
var _grapple_throw_position : Node3D;
var _thrown_grappling_hook : GrapplingHook;

func _ready() -> void:
	_camera = $Camera3D;
	_interact_raycast = $Camera3D/InteractRaycast;
	_grapple_raycast = $Camera3D/GrappleRaycast;
	_crosshair = $UI/Crosshair;
	_grapple_throw_position = $GrappleThrowPosition;
	
	_interact_raycast.add_exception(self);
	_grapple_raycast.add_exception(self);
	
	capture_mouse();

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	_mouse_captured = true;

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	_mouse_captured = false;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_look_direction = event.relative * look_speed;
		if _mouse_captured: _rotate_camera();
	if Input.is_action_just_pressed("Escape") and _mouse_captured:
		release_mouse();
	elif Input.is_action_just_pressed("Click") and !_mouse_captured:
		capture_mouse();

func _rotate_camera() -> void:
	_camera.rotation.y -= _look_direction.x;
	_camera.rotation.x = clamp(_camera.rotation.x - _look_direction.y, -1.5, 1.5);

func throw_grappling_hook(grappleable: Grappleable, hit_pos: Vector3) -> void:
	#if _thrown_grappling_hook:
	#	return;
	_thrown_grappling_hook = grappling_hook.instantiate();
	_thrown_grappling_hook.global_position = _grapple_throw_position.global_position;
	add_sibling(_thrown_grappling_hook);
	_thrown_grappling_hook.throw(grappleable, hit_pos, grapple_throw_strength);

func _physics_process(delta: float) -> void:
	
	if move_state == MoveState.CONTROLLED:
		return;
	
	# Add the gravity.
	if not is_on_floor():
		_v_speed += get_gravity().y * delta;

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		_v_speed = jump_strength;
	
	# Linear movement
	var move_vector = Input.get_vector("Left", "Right", "Forward", "Back") if is_on_floor() or move_state == MoveState.CLIMBING else _cur_direction;
	var target_speed : float = 0;
	
	if move_vector.length() > 0:
		_cur_direction = move_vector;
		match move_state:
			MoveState.WALKING:
				target_speed = walk_speed;
				if Input.is_action_pressed("Run"):
					target_speed = run_speed;
			MoveState.CLIMBING:
				target_speed = climb_speed;
	
	_h_speed = lerp(_h_speed, target_speed, acceleration * delta);
	
	match move_state:
		MoveState.WALKING:
			velocity = Vector3(_cur_direction.x, 0, _cur_direction.y) * _h_speed;
			velocity = velocity.rotated(Vector3.UP, _camera.rotation.y);
			velocity.y = _v_speed;
		MoveState.CLIMBING:
			_v_speed = 0;
			velocity = Vector3.ZERO;
			velocity.y = _h_speed * -_cur_direction.y;
	
	move_and_slide();
	
	_crosshair.state = Crosshair.State.Normal;
	
	# Interaction
	var interactable : Interactable = null;
	if _interact_raycast.is_colliding():
		var hit = _interact_raycast.get_collider();
		if hit is Interactable:
			interactable = hit as Interactable;
			_crosshair.state = Crosshair.State.Interact;
		
	
	if Input.is_action_just_pressed("Interact"):
		if interactable:
			interactable.interact();
	
	# Grapple
	var grappleable : Grappleable = null;
	var grapple_hit_pos : Vector3;
	if _grapple_raycast.is_colliding():
		var hit = _grapple_raycast.get_collider();
		if hit is Grappleable:
			grappleable = hit as Grappleable;
			grapple_hit_pos = _grapple_raycast.get_collision_point();
			_crosshair.state = Crosshair.State.Grapple;
	
	if Input.is_action_just_pressed("Grapple"):
		if grappleable:
			throw_grappling_hook(grappleable, grapple_hit_pos);
	
