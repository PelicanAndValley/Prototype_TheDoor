extends Interactable

class_name Anchor;

var _anchor_pos : Node3D;

@export
var audio : AudioStreamPlayer3D;
@export
var volume : float;
@export
var anim_tree : AnimationTree;
@export
var speed : float = 1;
@export
var rope : Node3D;

func _ready () -> void:
	on_interact.connect(self.interacting);
	_anchor_pos = $AnchorPos;

func interacting (player: Player, point: Vector3) -> void:
	if player._held_rope:
		rope.visible = true;
		player._held_rope.start_sound();
		player._held_rope.drop(_anchor_pos);

func can_interact (player: Player) -> bool:
	return !!player._held_rope;
