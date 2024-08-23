extends Item

class_name ItemBalloon;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null) -> void:
	var key = on as Key;
	key.dislodge();
	player.consume_current_item();
	#placed.look_at(placed.global_position - normal);
