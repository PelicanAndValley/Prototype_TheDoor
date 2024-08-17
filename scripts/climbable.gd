extends AnimatableBody3D

class_name Climbable;

@export
var clearance : float = 1.5;

var _top_exit_pos : Node3D;
var _bottom_exit_pos : Node3D;
var _climb_area : Area3D;
var _exit_pos : Vector3;
var _player : Player = null;
var _og_pos : Vector3;
var _hop_timer : float = 0;
var _hopping : bool = false;
var _exit_dir : Vector3;
var _just_entered : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_climb_area = $ClimbArea;
	_top_exit_pos = $TopExitPos;
	_bottom_exit_pos = $BottomExitPos;
	_climb_area.body_entered.connect(self.on_body_entered_climb);
	_climb_area.body_exited.connect(self.on_body_exited_climb);

func grow_collision_cylinder(shape: CollisionShape3D, scale):
	var cylinder = shape.shape as CylinderShape3D;
	cylinder.height = scale;
	shape.position.y = -scale / 2;

func exit_to_pos (pos: Vector3) -> void:
	if _hopping:
		return;
	_player.move_state = Player.MoveState.CONTROLLED;
	_og_pos = _player.global_position;
	_exit_pos = pos;
	_hop_timer = 0;
	_hopping = true;

func _physics_process(delta: float) -> void:
	# Move player on exit
	if _player:
		if _hopping:
			_hop_timer += delta;
			var ended = false;
			if _hop_timer >= _player.hop_time:
				_hop_timer = _player.hop_time;
				ended = true;
			#_player.velocity = 
			if ended:
				_player.move_state = Player.MoveState.WALKING;
				_player = null;
				_hopping = false;
		elif _player.is_on_floor():
			if !_just_entered:
				pass;
				#var climbable_ref_pos = Vector3(global_position.x, _player.global_position.y, global_position)
				#exit_to_pos();
		else:
			_just_entered = false;


func on_body_entered_climb(body: Node3D) -> void:
	if body is Player and !_hopping:
		print("PLAYER CLIMBING");
		_player = body as Player;
		_player.move_state = Player.MoveState.CLIMBING;
		_just_entered = true;

func on_body_exited_climb(body: Node3D) -> void:
	if body is Player and !_hopping:
		exit_to_pos(_top_exit_pos.global_position);
