extends CollisionObject3D;

class_name Interactable;

signal on_interact (player, point);

@export
var link_to_item : bool = false;
@export
var item_names : PackedStringArray;

func can_interact (player: Player) -> bool:
	print(str("INTERACT ", name));
	if !link_to_item:
		return true;
	if !player.current_item:
		return false;
	for name in item_names:
		if player.current_item.name == name:
			return true;
	return false;

func interact (player: Player, point: Vector3, normal: Vector3) -> void:
	if can_interact(player):
		if link_to_item:
			player.current_item.use(player, point, normal, self);
		on_interact.emit(player, point);
