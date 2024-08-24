extends EditorNode3DGizmoPlugin;

class_name DynamicWindGizmo;

const INNER_MESH : Mesh = preload("res://addons/dynamic_wind/wind_arrow_mesh.res");
#const OUTER_MESH : Mesh = preload("res://addons/dynamic_wind/wind_arrow_outline_mesh.res")

func _get_gizmo_name():
	return "DynamicWind";

func _has_gizmo(node):
	return node is DynamicWindForce;

func _init():
	#create_material("inner", Color(0.3, 0.7, 1.0, 0.8), false, true);
	create_material("outline", Color(1, 1, 1, 0.8));
	create_handle_material("handles")


func _redraw(gizmo):
	gizmo.clear()

	var node3d = gizmo.get_node_3d()

	var lines = PackedVector3Array()

	lines.push_back(Vector3(0, 1, 1))
	lines.push_back(Vector3(0, 0, 0))

	#var handles = PackedVector3Array()

	#handles.push_back(Vector3(1, 1, 0))
	#handles.push_back(Vector3(0, 1, 1))

	#gizmo.add_lines(lines, get_material("main", gizmo), false)
	#gizmo.add_handles(handles, get_material("handles", gizmo), [])
	gizmo.add_mesh(INNER_MESH, get_material("outline", gizmo));
	#gizmo.add_mesh(OUTER_MESH, get_material("outline", gizmo));
