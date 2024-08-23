extends Interactable

class_name AnchorPoint;

@export
var pulley_system : Node3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_interact.connect(self.enable_pulley);

func enable_pulley (player : Player, point : Vector3) -> void:
	player.consume_current_item();
	pulley_system.visible = true;
	pulley_system.process_mode = Node.PROCESS_MODE_INHERIT;
