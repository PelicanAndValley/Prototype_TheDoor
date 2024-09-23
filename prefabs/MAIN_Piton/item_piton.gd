extends Item

class_name ItemPiton;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null) -> void:
	player.effect_player.stream = player.item_pickup_sound;
	player.effect_player.play();
