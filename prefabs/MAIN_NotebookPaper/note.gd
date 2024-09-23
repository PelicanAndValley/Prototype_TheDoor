extends Interactable

class_name Note;

@export
var text : String;

func _ready() -> void:
	on_interact.connect(_on_picked_up);

func _on_picked_up (player: Player, point: Vector3) -> void:
	var notebook := player.door_ui.notebook as Notebook;
	notebook.add_note(text);
	player.effect_player.stream = player.notebook_sound;
	player.effect_player.play();
	player.door_ui.open_notebook();
	queue_free();
