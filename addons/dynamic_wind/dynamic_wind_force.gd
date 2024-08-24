@tool
extends Node3D

class_name DynamicWindForce

var _parent_wind_area : DynamicWindArea;
var _config_warnings : PackedStringArray = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			load_parent_wind_area();
		NOTIFICATION_PARENTED:
			load_parent_wind_area();

func load_parent_wind_area () -> void:
	if get_parent_node_3d() is DynamicWindArea:
		_parent_wind_area = get_parent_node_3d() as DynamicWindArea;
		_config_warnings = [];
	else:
		_parent_wind_area = null;
		_config_warnings = ["DynamicWindForce provides a force to a DynamicWindArea, please make sure this is parented to a DynamicWindArea node."];

# Return stored value
func _get_configuration_warnings() -> PackedStringArray:
	return _config_warnings;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
