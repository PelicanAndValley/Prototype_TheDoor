@tool
extends EditorPlugin

var gizmo = DynamicWindGizmo.new();

func _enter_tree() -> void:
	add_custom_type("DynamicWindArea", "Area3D", preload("dynamic_wind_area.gd"), preload("res://addons/dynamic_wind/icons/DynamicWindArea.svg"));
	add_custom_type("DynamicWindMesh", "Area3D", preload("dynamic_wind_mesh.gd"), preload("res://addons/dynamic_wind/icons/DynamicWindMesh.svg"));
	add_custom_type("DynamicWindForce", "Node3D", preload("dynamic_wind_force.gd"), preload("res://addons/dynamic_wind/icons/DynamicWindForce.svg"));
	add_node_3d_gizmo_plugin(gizmo);


func _exit_tree() -> void:
	remove_custom_type("DynamicWindArea");
	remove_custom_type("DynamicWindMesh");
	remove_custom_type("DynamicWindForce");
	remove_node_3d_gizmo_plugin(gizmo);
