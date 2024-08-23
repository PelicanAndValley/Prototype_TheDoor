extends EditorNode3DGizmoPlugin;

class_name DynamicWindGizmo;

#const MESH : Mesh = preload("res://prefabs/MAIN_Door_Base/Door_Base.glb::ArrayMesh_kpks4");

func _get_gizmo_name():
	return "DynamicWind";

func _has_gizmo(node):
	return node is DynamicWindArea;

func _init():
	create_material("main", Color(1, 0, 1))
	create_handle_material("handles")


func _redraw(gizmo):
	gizmo.clear()

	var node3d = gizmo.get_node_3d()

	var lines = PackedVector3Array()

	lines.push_back(Vector3(0, 1, 1))
	lines.push_back(Vector3(-1, -1, 0))

	#var handles = PackedVector3Array()

	#handles.push_back(Vector3(1, 1, 0))
	#handles.push_back(Vector3(0, 1, 1))

	gizmo.add_lines(lines, get_material("main", gizmo), false)
	#gizmo.add_handles(handles, get_material("handles", gizmo), [])
	#gizmo.add_mesh(MESH, get_material("main", gizmo));
