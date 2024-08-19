extends Item

class_name ItemBalloon;

@export
var place_balloon : PackedScene;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null) -> void:
	var placed : PlaceBalloon = place_balloon.instantiate();
	var key = on as Key;
	on.add_child(placed);
	placed.global_position = key._balloon_pos.global_position;
	placed.attach_pos = key._balloon_pos;
	key.dislodge();
	player.consume_current_item();
	#placed.look_at(placed.global_position - normal);
