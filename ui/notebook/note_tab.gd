extends TextureButton

class_name NoteTab;

signal tab_pressed (index);

var _rich_text : RichTextLabel;
var idx : int = 0;
var text : String:
	set(newval):
		_rich_text.text = newval;
	get():
		return _rich_text.text;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rich_text = $RichTextLabel;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	tab_pressed.emit(idx);
