extends Item

class_name ItemBoathook;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null) -> void:
	var key = on as Key;
	if key._in_place:
		print("USED BOATHOOK");
		key.put_in_lock()
		player.consume_current_item();
		#placed.look_at(placed.global_position - normal);
