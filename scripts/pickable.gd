extends Interactable

class_name Pickable;

@export
var item : PackedScene;

func _ready () -> void:
	on_interact.connect(self.on_interacted);

func on_interacted (player: Player, point: Vector3) -> void:
	player.equip_item(item);
	queue_free();
