extends CollisionObject3D;

class_name Interactable;

signal on_interact (player);

func interact (player: Player) -> void:
	on_interact.emit(player);
