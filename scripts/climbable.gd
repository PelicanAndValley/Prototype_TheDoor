extends AnimatableBody3D

class_name Climbable;

@export
var top_exit_pos : Node3D;
@export
var bottom_exit_pos : Node3D;

var _top_exit_area : Area3D;
var _bottom_exit_area : Area3D;
var _exit_pos : Node3D;
var _player : Player = null;
var _og_pos : Vector3;
var _hop_timer : float = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_top_exit_area = $TopExitArea;
	_bottom_exit_area = $BottomExitArea;
	_top_exit_area.body_entered.connect(self.on_body_entered_top_exit);
	_bottom_exit_area.body_entered.connect(self.on_body_entered_bottom_exit);

func grow_collision_cylinder(shape: CollisionShape3D, scale):
	var cylinder = shape.shape as CylinderShape3D;
	cylinder.height = scale;
	shape.position.y = -scale / 2;

func _physics_process(delta: float) -> void:
	# Move player on exit
	if _player:
		_hop_timer += delta;
		if _hop_timer >= _player.hop_time:
			_hop_timer = _player.hop_time;
			_player.move_state = Player.MoveState.WALKING;
		_player.global_position = lerp(_og_pos, _exit_pos.global_position, _hop_timer / _player.hop_time);


func on_body_entered_rope(body: Node3D) -> void:
	if body is Player:
		var player = body as Player;
		player.move_state = Player.MoveState.CLIMBING;

func on_body_exited_rope(body: Node3D) -> void:
	if body is Player:
		var player = body as Player;
		player.move_state = Player.MoveState.WALKING;

func on_body_entered_top_exit(body: Node3D) -> void:
	if body is Player:
		_player = body as Player;
		_player.move_state = Player.MoveState.CONTROLLED;
		_og_pos = _player.global_position;
		_exit_pos = top_exit_pos;
		_hop_timer = 0;

func on_body_entered_bottom_exit(body: Node3D) -> void:
	if body is Player:
		_player = body as Player;
		_player.move_state = Player.MoveState.CONTROLLED;
		_og_pos = _player.global_position;
		_exit_pos = bottom_exit_pos;
		_hop_timer = 0;
