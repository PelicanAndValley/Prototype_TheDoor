extends Interactable

class_name Pickable;

@export
var item : PackedScene;

func _ready () -> void:
	on_interact.connect(self.on_interacted);

func on_interacted (player: Player, point: Vector3) -> void:
	player.equip_item(item);
	player.effect_player.stream = player.item_pickup_sound;
	player.effect_player.play();
	queue_free();
