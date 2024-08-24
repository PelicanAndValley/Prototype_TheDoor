@tool
extends Area3D;

class_name DynamicWindArea;

var _child_forces : Array[DynamicWindForce] = [];
var _config_warnings : PackedStringArray = [];

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			load_child_forces();
		NOTIFICATION_PARENTED:
			load_child_forces();

func load_child_forces () -> void:
	_child_forces = [];
	for child in get_children():
		if child is DynamicWindForce:
			_child_forces.append(child as DynamicWindForce);
	if _child_forces.size() == 0:
		_config_warnings = ["This node contains no forces and so will have no effect. Add DynamicWindForce children to provide direction to the wind."];
	else:
		_config_warnings = [];

# Return stored value
func _get_configuration_warnings() -> PackedStringArray:
	return _config_warnings;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass
