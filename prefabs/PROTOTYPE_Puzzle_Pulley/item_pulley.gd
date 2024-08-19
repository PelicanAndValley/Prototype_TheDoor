extends Item

class_name ItemPulley

@export
var hanging_rope : PackedScene;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null):
	print("USED");
	var key = on as Key;
	key.has_rope = true;
	var rope : HangingRope = hanging_rope.instantiate();
	print(str("ADDING TO ", point));
	add_sibling(rope);
	rope.start = key._rope_pos;
	rope.hold(player);
	# Outside of player
	player.consume_current_item();
