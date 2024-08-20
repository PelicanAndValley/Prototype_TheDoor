extends Interactable

class_name Anchor;

var _anchor_pos : Node3D;

@export
var audio : AudioStreamPlayer3D;
@export
var volume : float;

func _ready () -> void:
	on_interact.connect(self.interacting);
	_anchor_pos = $AnchorPos;

func interacting (player: Player, point: Vector3) -> void:
	if player._held_rope:
		player._held_rope.start_sound();
		player._held_rope.drop(_anchor_pos);

func can_interact (player: Player) -> bool:
	return !!player._held_rope;
