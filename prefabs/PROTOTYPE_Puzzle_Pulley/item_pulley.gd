extends Item

class_name ItemPulley

@export
var hanging_rope : PackedScene;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null):
	var key = on as Key;
	key.has_rope = true;
	var rope : HangingRope = hanging_rope.instantiate();
	add_sibling(rope);
	rope.start = key._rope_pos;
	rope.hold(player);
	# Outside of player
	player.effect_player.stream = player.item_pickup_sound;
	player.effect_player.play();
	player.consume_current_item();
