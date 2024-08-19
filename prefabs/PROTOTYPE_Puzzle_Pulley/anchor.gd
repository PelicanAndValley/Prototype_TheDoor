extends Interactable

var _anchor_pos : Node3D;

func _ready () -> void:
	on_interact.connect(self.interacting);
	_anchor_pos = $AnchorPos;

func interacting (player: Player, point: Vector3) -> void:
	if player._held_rope:
		player._held_rope.drop(_anchor_pos.global_position);

func can_interact (player: Player) -> bool:
	return !!player._held_rope;