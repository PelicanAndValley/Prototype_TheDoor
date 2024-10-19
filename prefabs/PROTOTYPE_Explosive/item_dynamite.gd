extends Item

class_name ItemDynamite;

@export
var placed_dynamite : PackedScene;

func use (player: Player, point: Vector3, normal: Vector3, on: Interactable = null) -> void:
	var dynamite_model : PlacedDynamite = placed_dynamite.instantiate();
	var chain = on as Chain;
	chain.add_dynamite(dynamite_model);
	dynamite_model.global_position = point;
	player.consume_current_item();
	
