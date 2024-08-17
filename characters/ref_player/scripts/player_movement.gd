@tool
extends CharacterBody3D
class_name PlayerController

@export_group("Movement")
@export
var walk_speed : float = 1;
@export
var run_speed : float = 2;
@export
var sprint_speed : float = 3;
@export
var attacking_speed : float = 0;
@export
var run_threshold : float = 0.5;
@export
var acceleration : float = 1;
@export
var dodge_length : float = 1;
@export
var sprint_hold_time : float = 1;

@export_group("Camera")
@export
var turn_speed : float = 1;
@export
var look_sensitivity : Vector2;
@export
var look_limit : float = PI / 2;
@export
var camera_forward_strength : float = 0;
@export
var camera_dist : float = 10:
	set(new_camera_dist):
		camera_dist = new_camera_dist;
		if _sphere_cast:
			_sphere_cast.target_position = Vector3(0, 1, camera_dist);
@export
var camera_dodge_follow_speed : float = 10;
@export
var camera_collision_spacing : float = 0.1;

@export_group("Attacks")
@export
var attack_input_time : float = 0.5;

enum PlayerState {IDLE, MOVING, STOPPING, DODGING, JUMPING, BACKSTEPPING, ATTACKING, BLOCKING};
var player_state : PlayerState = PlayerState.IDLE;

enum MoveState {WALK, RUN, SPRINT};
var move_state : MoveState = MoveState.WALK;

enum RequestFlags {ATTACK = 1, DODGEROLL = 2};
var request_flags : int = 0;

var _camera : Camera3D;
var _camera_height_pivot : Node3D;
var _camera_forward_pivot : Node3D;
var _player_body : Node3D;
var _animation_tree : AnimationTree;
var _attack_playback : AnimationNodeStateMachinePlayback;
var _sphere_cast : ShapeCast3D;
var _camera_target : BoneAttachment3D;
var _moveability_bone : BoneAttachment3D;
var _turnability_bone : BoneAttachment3D;
var _x_rotation : float = 0;
var _y_rotation : float = 0;
var _cur_speed : float = 0;
var _cur_direction : Vector3 = Vector3.FORWARD;
var _sprint_hold_timer : float = 0;
var _dodge_timer : float = 0;
var _attack_started : bool = false;

var _config_warnings : PackedStringArray = [];


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_camera_forward_pivot = $CameraForwardPivot;
	#_camera_height_pivot = $CameraForwardPivot/CameraHeightPivot;
	#_camera = $CameraForwardPivot/CameraHeightPivot/PlayerCamera;
	#_player_body = $PlayerModel;
	#_animation_tree = $PlayerModel/AnimationTree;
	#_sphere_cast = $SphereCast;
	
	initialize_children();
	_sphere_cast.add_exception(self);
	_sphere_cast.target_position = Vector3(0, 2, camera_dist);
	#print("Vibrating controller: ", connected_devices[0]);
	#Input.start_joy_vibration(connected_devices[0], 1, 1);
	var connected_devices = Input.get_connected_joypads();
	if connected_devices.size() == 0:
		print("Couldn't find controller! Please restart!");


# Initialize all references to child nodes
func initialize_children () -> void:
	var required_nodes = get_required_children([
		"CameraForwardPivot",
		"CameraForwardPivot/CameraHeightPivot",
		"CameraForwardPivot/CameraHeightPivot/PlayerCamera",
		"PlayerModel",
		"PlayerModel/AnimationTree",
		"SphereCast",
		"PlayerModel/PlayerArmature/Skeleton3D/CameraTarget",
		"PlayerModel/PlayerArmature/Skeleton3D/Moveability",
		"PlayerModel/PlayerArmature/Skeleton3D/Turnability"
	]);
	_camera_forward_pivot = required_nodes[0];
	_camera_height_pivot = required_nodes[1];
	_camera = required_nodes[2];
	_player_body = required_nodes[3];
	_animation_tree = required_nodes[4];
	_sphere_cast = required_nodes[5];
	_camera_target = required_nodes[6];
	_moveability_bone = required_nodes[7];
	_turnability_bone = required_nodes[8];
	
	if _animation_tree:
		_attack_playback = _animation_tree.get("parameters/MeleeComboAnimation/playback");


# Fetch child nodes by name, and log warnings when missing
func get_required_children (names: Array[String]) -> Array:
	var nodes = [];
	_config_warnings = [];
	for name in names:
		var node = get_node_or_null(name);
		if !node:
			_config_warnings.append(str("Missing child node ", name, "!"));
		nodes.append(node);
	return nodes;


# Return stored value
func _get_configuration_warnings() -> PackedStringArray:
	return _config_warnings;


func _notification(what):
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			# Reinitialize child nodes
			initialize_children();

func animation_finished(anim_name: StringName) -> void:
	match(anim_name):
		"DodgeRoll":
			# Stop dodding, reset after animation and move player
			player_state = PlayerState.IDLE;

func animation_started(anim_name: StringName) -> void:
	match(anim_name):
		"MeleeCombo1":
			_attack_started = true;

# Utilities

# Rotates player body to face motion smoothly according to turn_speed
func face_motion (delta: float, turnspeed: float = turn_speed) -> void:
	_player_body.basis.z = lerp(_player_body.basis.z, -_cur_direction, turnspeed * delta).normalized();
	_player_body.basis.x = _player_body.basis.z.rotated(Vector3.UP, PI/2);
	_player_body.basis.y = Vector3.UP;
	
# Smooth speed change according to acceleration
func lerp_to_speed (speed: float, delta: float) -> void:
	_cur_speed = lerp(_cur_speed, speed, acceleration * delta);
	velocity = _cur_direction.normalized() * _cur_speed * delta;
	
# Toggles a flag in the input requests
func set_request_flag (flag: RequestFlags) -> void:
	request_flags = request_flags | flag;
	
func unset_request_flag (flag: RequestFlags) -> void:
	request_flags = request_flags & (~flag);
	
# Get a request flag value
func is_request_flagged (flag: RequestFlags) -> bool:
	return request_flags & flag;
	
func clear_input_requests () -> void:
	request_flags = 0;
	
func increment_name (anim_name: StringName):
	var start = anim_name.substr(0, anim_name.length() - 1);
	var end = int(anim_name.substr(anim_name.length() - 1, 1));
	return str(start, end+1);

# Movement/physics logic
func _physics_process(delta: float) -> void:
	
	# Game only
	if Engine.is_editor_hint():
		return;
	
	# Control vectors
	var look_vector = Input.get_vector("LookRight", "LookLeft", "LookUp", "LookDown");
	var input_move_vector = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack");
	var move_vector = (_camera_forward_pivot.basis.x * input_move_vector.x) + (_camera_forward_pivot.basis.z * input_move_vector.y);
	
	# Camera rotation
	var x_look_angle = -look_vector.y * look_sensitivity.y * delta;
	_x_rotation += x_look_angle;
	_x_rotation = clampf(_x_rotation, -look_limit, look_limit);
	_camera_height_pivot.rotation.x = _x_rotation;
	_camera_forward_pivot.rotation.y += look_vector.x * look_sensitivity.x * delta;
	var lengths_squared = _camera_forward_pivot.global_basis.z.length_squared() * _player_body.global_basis.z.length_squared();
	var camera_cross = _camera_forward_pivot.global_basis.z.cross(_player_body.global_basis.z);
	var camera_deviation = camera_cross.y;
	if look_vector.length() == 0 && move_vector.length() > 0:
		_camera_forward_pivot.rotation.y += camera_forward_strength * delta * camera_deviation;
	
	# Bring camera forward from objects in front
	var raycast_target = _camera_forward_pivot.basis.z * camera_dist;
	_sphere_cast.target_position = raycast_target;
	var result = _sphere_cast.collision_result;
	var dist = camera_dist;
	if result.size() > 0:
		dist = _camera_height_pivot.global_position.distance_to(result[0].point) - camera_collision_spacing;
	
	_camera.position = Vector3.BACK * dist;
	
	
	if move_vector.length() <= run_threshold:
		move_state = MoveState.WALK;
	else:
		move_state = MoveState.RUN;
	
	# Physics-based transition checks
	match player_state:
		PlayerState.MOVING:
			if move_vector.length() == 0:
				player_state = PlayerState.IDLE;
				move_state = MoveState.RUN;
				_sprint_hold_timer = 0;
		PlayerState.IDLE:
			if move_vector.length() > 0:
				player_state = PlayerState.MOVING;
	
	# Behaviour
	match player_state:
		
		PlayerState.ATTACKING:
			# Movement and direction
			_cur_direction = move_vector.normalized();
			_cur_speed = _moveability_bone.global_position.y * run_speed;
			velocity = _cur_direction * _cur_speed * delta;
			face_motion(delta, turn_speed * _turnability_bone.global_position.y);
			move_and_slide();
		
		PlayerState.DODGING:
			# Rotate body to face motion
			face_motion(delta);
			var anim_time = _animation_tree.get_animation("DodgeRoll").length;
			velocity = _cur_direction * (dodge_length / anim_time);
			move_and_slide();
			
		PlayerState.IDLE, PlayerState.MOVING:
			# Set speed
			var target_speed : float = 0;
			var animation_gradient = -1;
			if move_vector.length() > 0 and player_state != PlayerState.IDLE:
				# Always retain last "moving" direction
				_cur_direction = move_vector.normalized();
				face_motion(delta);
				# Determine linear speed
				match move_state:
					MoveState.WALK:
						target_speed = walk_speed;
					MoveState.RUN:
						target_speed = run_speed;
					MoveState.SPRINT:
						target_speed = sprint_speed;
			lerp_to_speed(target_speed, delta);
			move_and_slide();

# Animation logic
func _process (delta: float) -> void:
	
	# Game only
	if Engine.is_editor_hint():
		return;
	
	# Parse input to get player and move state
	if Input.is_action_just_pressed("NormalAttack"):
		set_request_flag(RequestFlags.ATTACK);
		print("Attack requested...");
	elif Input.is_action_pressed("DodgeSprint"):
		if _sprint_hold_timer >= sprint_hold_time && player_state == PlayerState.MOVING:
			move_state = MoveState.SPRINT;
		else:
			_sprint_hold_timer += delta;
	elif Input.is_action_just_released("DodgeSprint"):
		if _sprint_hold_timer < sprint_hold_time:
			set_request_flag(RequestFlags.DODGEROLL);
		_sprint_hold_timer = 0;
	
	
	# Input requests in order of priority
	if is_request_flagged(RequestFlags.ATTACK):
		if player_state == PlayerState.MOVING or player_state == PlayerState.IDLE:
			print("Starting attack sequence!");
			player_state = PlayerState.ATTACKING;
			_animation_tree.set("parameters/MeleeCombo/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
			clear_input_requests();
	elif is_request_flagged(RequestFlags.DODGEROLL):
		if player_state == PlayerState.MOVING:
			player_state = PlayerState.DODGING;
			_dodge_timer = 0;
			_animation_tree.set("parameters/DoABarrelRoll/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
			clear_input_requests();
	
	# State dependent input request
	match player_state:
		PlayerState.ATTACKING:
			# Disable all but attack requests
			request_flags &= RequestFlags.ATTACK;
			# Check for more attack input
			var anim_length = _attack_playback.get_current_length();
			var anim_time = _attack_playback.get_current_play_position();
			var remaining = anim_length - anim_time;
			if remaining <= attack_input_time && is_request_flagged(RequestFlags.ATTACK):
				var anim = _attack_playback.get_current_node();
				if anim != "MeleeCombo3" and anim != "End":
					print(str("Continuing attack from ", anim));
					var anim_name = increment_name(anim);
					print(str("Travelling to ", anim_name));
					_attack_playback.travel(anim_name);
			elif !_animation_tree.get("parameters/MeleeCombo/active") and _attack_started:
				print("Sequence finished!");
				player_state = PlayerState.IDLE;
				_attack_started = false;
	
	clear_input_requests();
