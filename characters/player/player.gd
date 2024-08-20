extends CharacterBody3D

class_name Player;

@export_group("Movement")
@export
var walk_speed : float = 10;
@export
var run_speed : float = 30;
@export
var acceleration : float = 10;
@export_group("Jump")
@export
var jump_strength : float = 5;
@export
var air_speed : float = 3;
@export_group("Climbing")
@export
var climb_speed : float = 30;
@export
var climb_strafe_speed : float = 5;
@export
var hop_speed : float = 10;
@export_group("Camera")
@export
var look_speed : float = 0.001;
@export_group("Tools")
@export
var grappling_hook : PackedScene;
@export
var grapple_throw_strength : float = 20;
@export_group("UI")
@export
var door_ui : DoorUI;
@export_group("Sound")
@export
var effect_player : AudioStreamPlayer;
@export
var music_player : AudioStreamPlayer;
@export
var ambience_player : AudioStreamPlayer;
@export
var grapple_throw_sound : AudioStream;
@export
var item_pickup_sound : AudioStream;

var open_ui: DoorUI.OpenUI:
	get():
		return door_ui.open_ui;
	set(newval):
		door_ui.open_ui = newval;

enum MoveState { WALKING, CLIMBING, CONTROLLED };
var move_state = MoveState.WALKING;

var items = Array([], TYPE_OBJECT, "Node", Item);
var item_idx : int = 0;
var current_item : Item = null;

var _h_speed : float = 0;
var _cur_direction : Vector2 = Vector2.DOWN;
var _v_speed : float = 0;
var _mouse_captured = false;
var _look_direction : Vector2 = Vector2.ZERO;
var _camera : Camera3D;
var _interact_raycast : RayCast3D;
var _grapple_raycast : RayCast3D;
var _collision : CollisionShape3D;
var _crosshair : Crosshair;
var _grapple_throw_position : Node3D;
var _item_hold_pos : Node3D;
var _thrown_grappling_hook : GrapplingHook;
var _ui : Control;
var _climbing : Climbable;
var _item_hold_anim : AnimationNodeStateMachinePlayback;
var _held_rope : HangingRope = null;

func _ready() -> void:
	_camera = $Camera3D;
	_interact_raycast = $Camera3D/InteractRaycast;
	_grapple_raycast = $Camera3D/GrappleRaycast;
	_collision = $CollisionShape3D;
	_crosshair = $UI/Crosshair;
	_grapple_throw_position = $Camera3D/GrappleThrowPosition;
	_item_hold_pos = $Camera3D/ItemHoldPos;
	_ui = $UI;
	var item_hold_anim_tree : AnimationTree = $Camera3D/ItemHoldPos/AnimationTree;
	_item_hold_anim = item_hold_anim_tree["parameters/playback"];
	
	_interact_raycast.add_exception(self);
	_grapple_raycast.add_exception(self);
	
	door_ui.set_player(self);
	
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

func _rotate_camera() -> void:
	_camera.rotation.y -= _look_direction.x;
	_camera.rotation.x = clamp(_camera.rotation.x - _look_direction.y, -1.5, 1.5);

func throw_grappling_hook(grappleable: Grappleable, hit_pos: Vector3) -> void:
	_thrown_grappling_hook = grappling_hook.instantiate();
	add_sibling(_thrown_grappling_hook);
	_thrown_grappling_hook.global_position = _grapple_throw_position.global_position;
	_thrown_grappling_hook.throw(_grapple_throw_position.global_position, grappleable, hit_pos, grapple_throw_strength);
	consume_current_item();

func climb (climbable: Climbable) -> void:
	_climbing = climbable;
	move_state = MoveState.CLIMBING;

func exit_climb () -> void:
	_climbing = null;


func cycle_item () -> void:
	if items.size() == 0:
		current_item = null;
		return;
	_item_hold_anim.travel("item_swap_out");

func on_animation_finished (anim_name: StringName) -> void:
	if anim_name == "item_swap_out" and items.size() > 0:
		var new_item : Item = items[item_idx];
		if current_item:
			current_item.visible = false;
		new_item.visible = true;
		current_item = new_item;


func equip_item (item: PackedScene) -> void:
	var new_item : Item = item.instantiate();
	_item_hold_pos.add_child(new_item);
	new_item.global_position = _item_hold_pos.global_position;
	new_item.global_rotation = _item_hold_pos.global_rotation;
	new_item.visible = false;
	items.append(new_item);
	item_idx = items.size() - 1;
	cycle_item();

func consume_current_item () -> void:
	items.remove_at(item_idx);
	current_item.queue_free();
	current_item = null;
	if item_idx > items.size() - 1:
		item_idx = 0;
	cycle_item();


func _physics_process(delta: float) -> void:
	
	if move_state == MoveState.CONTROLLED:
		_h_speed = 0;
		_v_speed = 0;
		_collision.disabled = true;
		return;
	_collision.disabled = false;
	
	# Add the gravity.
	if not is_on_floor() and move_state == MoveState.WALKING:
		_v_speed += get_gravity().y * delta;

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and move_state == MoveState.WALKING:
		_v_speed = jump_strength;
	
	# Linear movement
	var move_vector = Input.get_vector("Left", "Right", "Forward", "Back");
	var target_speed : float = 0;
	# For climbing only
	var target_v_speed : float = 0;
	
	if move_vector.length() > 0:
		_cur_direction = move_vector;
		match move_state:
			MoveState.WALKING:
				target_speed = walk_speed;
				if Input.is_action_pressed("Run"):
					target_speed = run_speed;
			MoveState.CLIMBING:
				if abs(_cur_direction.x) > 0:
					target_speed = climb_strafe_speed;
				if abs(_cur_direction.y) > 0:
					target_v_speed = climb_speed;
	
	_h_speed = lerp(_h_speed, target_speed, acceleration * delta);
	
	match move_state:
		MoveState.WALKING:
			velocity = Vector3(_cur_direction.x, 0, _cur_direction.y) * _h_speed;
			velocity = velocity.rotated(Vector3.UP, _camera.rotation.y);
			velocity.y = _v_speed;
		MoveState.CLIMBING:
			_v_speed = lerp(_v_speed, target_v_speed, acceleration * delta);
			velocity = Vector3.ZERO;
			velocity.y = _v_speed * -_cur_direction.y;
			#velocity += _h_speed * _cur_direction.x * _climbing.global_basis.z;
	
	move_and_slide();
	
	if Input.is_action_just_pressed("ItemCycleUp"):
		item_idx += 1;
		if item_idx > items.size() - 1:
			item_idx = 0;
		cycle_item();
	elif Input.is_action_just_pressed("ItemCycleDown"):
		item_idx -= 1;
		if item_idx < 0:
			item_idx = items.size() - 1;
		cycle_item();
	
	_crosshair.state = Crosshair.State.Normal;
	if move_state != MoveState.CLIMBING:
		# Interaction
		var interactable : Interactable = null;
		var interact_hit_pos : Vector3;
		var interact_hit_normal : Vector3;
		if _interact_raycast.is_colliding():
			var hit = _interact_raycast.get_collider();
			if hit is Interactable:
				interactable = hit as Interactable;
				if interactable.can_interact(self):
					interact_hit_pos = _interact_raycast.get_collision_point();
					interact_hit_normal = _interact_raycast.get_collision_normal();
					_crosshair.state = Crosshair.State.Interact;
				else:
					interactable = null;
		
		if Input.is_action_just_pressed("Interact"):
			if interactable:
				interactable.interact(self, interact_hit_pos, interact_hit_normal);
		
		# Grapple
		var grappleable : Grappleable = null;
		var grapple_hit_pos : Vector3;
		if _grapple_raycast.is_colliding() and current_item is ItemGrapplingHook:
			var hit = _grapple_raycast.get_collider();
			if hit is Grappleable:
				grappleable = hit as Grappleable;
				grapple_hit_pos = _grapple_raycast.get_collision_point();
				_crosshair.state = Crosshair.State.Grapple;
		
		if Input.is_action_just_pressed("Interact"):
			if grappleable:
				throw_grappling_hook(grappleable, grapple_hit_pos);
	#print(move_state);
