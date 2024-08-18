extends CollisionObject3D;

class_name Interactable;

signal on_interact (player, point);

@export
var link_to_item : bool = false;
@export
var item_name : String;

func can_interact (player: Player) -> bool:
	if !link_to_item:
		return true;
	if !player.current_item:
		return false;
	return player.current_item.name == item_name;

func interact (player: Player, point: Vector3, normal: Vector3) -> void:
	if link_to_item and can_interact(player):
		player.current_item.use(player, point, normal, self);
	on_interact.emit(player, point);
