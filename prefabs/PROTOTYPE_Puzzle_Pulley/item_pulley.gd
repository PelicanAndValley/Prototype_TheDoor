extends Item

class_name ItemPulley

@export
var hanging_rope : PackedScene;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null):
	print("USED");
	var key = on as Key;
	var rope : HangingRope = hanging_rope.instantiate();
	print(str("ADDING TO ", point));
	get_node("../../../../../..").add_sibling(rope);
	rope.start_pos = key._rope_pos.global_position;
	rope.global_position = key._rope_pos.global_position;
	rope.hold(player);
	# Outside of player
	player.consume_current_item();
