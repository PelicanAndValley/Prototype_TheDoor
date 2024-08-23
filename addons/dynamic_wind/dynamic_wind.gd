@tool
extends EditorPlugin

var gizmo = DynamicWindGizmo.new();

func _enter_tree() -> void:
	add_custom_type("DynamicWindArea", "Area3D", preload("dynamic_wind_area.gd"), preload("res://icon.svg"));
	add_custom_type("DynamicWindObject", "Area3D", preload("dynamic_wind_object.gd"), preload("res://icon.svg"));
	add_node_3d_gizmo_plugin(gizmo);


func _exit_tree() -> void:
	remove_custom_type("DynamicWindArea");
	remove_custom_type("DynamicWindObject");
	remove_node_3d_gizmo_plugin(gizmo);
