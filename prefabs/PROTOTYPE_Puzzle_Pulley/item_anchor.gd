extends Item

class_name ItemAnchor

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null):
	player.effect_player.stream = player.item_pickup_sound;
	player.effect_player.play();
