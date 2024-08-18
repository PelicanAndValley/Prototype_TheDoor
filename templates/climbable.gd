extends AnimatableBody3D

class_name Climbable;

@export
var clearance : float = 1.5;
@export
var top_mount_radius : float = 3;

var _top_hop_pos : Node3D;
var _bottom_hop_pos : Node3D;
var _top_mount_pos : Node3D;
var _climb_area : Area3D;
var _boundaries : Node3D;
var _hop_pos : Vector3;
var _hop_y_rot : float;
var _player : Player = null;
var _og_pos : Vector3;
var _just_entered : bool = false;
var _hopping : bool = false;

enum HopType { MOUNT, EXIT };
var _hop_type : HopType = HopType.EXIT;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_climb_area = $ClimbArea;
	_top_hop_pos = $TopExitPos;
	_top_mount_pos = $TopMountPos;
	_boundaries = $Boundaries;
	_climb_area.body_entered.connect(self.on_body_entered_climb);
	_climb_area.body_exited.connect(self.on_body_exited_climb);

func grow_collision_cylinder(shape: CollisionShape3D, scale):
	var cylinder = shape.shape as CylinderShape3D;
	cylinder.height = scale;
	shape.position.y = -scale / 2;

func player_hop (pos: Vector3, y_rot: float) -> void:
	if _hopping:
		return;
	_player.move_state = Player.MoveState.CONTROLLED;
	_og_pos = _player.global_position;
	_hop_pos = pos;
	_hop_y_rot = y_rot;
	_hopping = true;

func exit_to_transform (pos: Node3D) -> void:
	if _hopping:
		return;
	_hop_type = HopType.EXIT;
	player_hop(pos.global_position, pos.global_rotation.y);

func exit_to_pos (pos: Vector3) -> void:
	if _hopping:
		return;
	_hop_type = HopType.EXIT;
	player_hop(pos, _player.global_rotation.y);

func mount_to_transform (pos: Node3D) -> void:
	if _hopping:
		return;
	_hop_type = HopType.MOUNT;
	player_hop(pos.global_position, pos.global_rotation.y);

func begin_climb (player: Player) -> void:
	_player.climb(self);
	_just_entered = true;
	_boundaries.process_mode = Node.PROCESS_MODE_INHERIT;

func _physics_process(delta: float) -> void:
	# Move player on exit
	if _player:
		if _hopping:
			var ended = false;
			if _player.global_position.distance_to(_hop_pos) < 0.1:
				ended = true;
			_player.global_position = lerp(_player.global_position, _hop_pos, _player.hop_speed * delta);
			if ended:
				match _hop_type:
					HopType.EXIT:
						_player.exit_climb();
						_player.move_state = Player.MoveState.WALKING;
						_boundaries.process_mode = Node.PROCESS_MODE_DISABLED;
						_player = null;
					HopType.MOUNT:
						begin_climb(_player);
				_hopping = false;
		elif _player.is_on_floor():
			if !_just_entered:
				var clearance_pos = _player.global_position + (global_basis.z * clearance);
				exit_to_pos(clearance_pos);
		else:
			_just_entered = false;

func on_top_mount_interact(player: Player, _point: Vector3) -> void:
	_player = player;
	mount_to_transform(_top_mount_pos);

func on_body_entered_climb(body: Node3D) -> void:
	if body is Player and !_hopping:
		_player = body as Player;
		begin_climb(_player);

func on_body_exited_climb(body: Node3D) -> void:
	if body is Player and !_hopping and body.global_position.y - _top_hop_pos.global_position.y < top_mount_radius:
		var local_x_offset = body.to_local(_top_hop_pos.global_position).x * _top_hop_pos.basis.x;
		exit_to_pos(_top_hop_pos.global_position - local_x_offset);