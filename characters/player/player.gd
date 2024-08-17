extends CharacterBody3D


@export
var walk_speed : float = 10;
@export
var run_speed : float = 30;
@export
var acceleration : float = 10;
@export
var jump_strength : float = 5;
@export
var look_speed : float = 0.001;

var _h_speed : float = 0;
var _cur_direction : Vector2 = Vector2.DOWN;
var _v_speed : float = 0;
var _mouse_captured = false;
var _look_direction : Vector2 = Vector2.ZERO;
var _camera : Camera3D;
var _raycast : RayCast3D;
var _crosshair : Crosshair;

func _ready() -> void:
	_camera = $Camera3D;
	_raycast = $Camera3D/RayCast3D;
	_crosshair = $UI/Crosshair;
	
	_raycast.add_exception(self);
	
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

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		_v_speed += get_gravity().y * delta;

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		_v_speed = jump_strength;
	
	# Linear movement
	var move_vector = Input.get_vector("Left", "Right", "Forward", "Back") if is_on_floor() else _cur_direction;
	var target_speed : float = 0;
	
	if move_vector.length() > 0:
		_cur_direction = move_vector;
		target_speed = walk_speed;
		if Input.is_action_pressed("Run"):
			target_speed = run_speed;
	
	_h_speed = lerp(_h_speed, target_speed, acceleration * delta);
	
	move_and_slide();
	
	velocity = Vector3(move_vector.x, 0, move_vector.y) * _h_speed;
	velocity = velocity.rotated(Vector3.UP, _camera.rotation.y);
	velocity.y = _v_speed;
	
	# Interaction
	var interactable : Interactable = null;
	if _raycast.is_colliding():
		var hit = _raycast.get_collider();
		if hit is Interactable:
			interactable = hit as Interactable;
	
	_crosshair.can_interact = !!interactable;
	
	if Input.is_action_just_pressed("Interact"):
		if interactable:
			interactable.interact();
