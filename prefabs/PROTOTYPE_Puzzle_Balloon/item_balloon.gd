extends Item

class_name ItemBalloon;

@export
var place_balloon : PackedScene;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null) -> void:
	var placed : Node3D = place_balloon.instantiate();
	on.add_child(placed);
	placed.global_position = point;
	placed.look_at(placed.global_position - normal);
