extends AnimatableBody3D

class_name Platform;

var _player : Player;

func on_trigger_exit (body: Node3D) -> void:
	if body is Player:
		print("TRIGGER EXIT");
		_player = body as Player;

func on_trigger (body: Node3D) -> void:
	if body is Player:
		print("TRIGGERED");
		_player = body as Player;

#func _physics_process(delta: float) -> void:
	
