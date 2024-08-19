extends OpenableUI;

@export
var title : RichTextLabel;
@export
var page1 : RichTextLabel;
@export
var page2 : RichTextLabel;
var notes : PackedStringArray;
@export
var start_notes : PackedStringArray;
@export
var tabs : VBoxContainer;
@export
var note_tab : PackedScene;
@export
var page_number : RichTextLabel;

var _note_idx : int = 0;
var _page_idx : int = 0;
var _cur_title : String;
var _cur_note : PackedStringArray;

func round_up (num: float) -> int:
	var n = roundf(num);
	if n < num:
		n += 1;
	return int(n);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for note in start_notes:
		add_note(note);
	_note_idx = 0;
	load_note();

func add_note (note: String) -> void:
	notes.push_back(note);
	_note_idx = notes.size() - 1;
	load_note();
	var new_tab : NoteTab = note_tab.instantiate();
	tabs.add_child(new_tab);
	new_tab.text = _cur_title;
	new_tab.idx = _note_idx;
	new_tab.tab_pressed.connect(self.on_tab_pressed);

func load_note () -> void:
	var note : String = notes[_note_idx];
	var split : PackedStringArray = note.split("/", false);
	_cur_title = split[0];
	title.text = _cur_title;
	_cur_note = split.slice(1);
	_page_idx = 0;
	load_pages();

func load_pages () -> void:
	if _cur_note.size() == 0:
		return;
	var page1_text = _cur_note[_page_idx];
	page1.text = page1_text;
	if _cur_note.size() > _page_idx + 1:
		var page2_text = _cur_note[_page_idx + 1];
		page2.text = page2_text;
	else:
		page2.text = "";
	var cur_page_num = round_up(float(_page_idx + 1) / 2);
	var total_page_num = round_up(float(_cur_note.size()) / 2);
	page_number.text = str("[center]", cur_page_num, " / ", total_page_num);


func next_page () -> void:
	_page_idx += 2;
	if _page_idx > _cur_note.size() - 1:
		_page_idx -= 2;
	load_pages();

func prev_page () -> void:
	_page_idx -= 2;
	if _page_idx < 0:
		_page_idx += 2;
	load_pages();

func _process (delta) -> void:
	if Input.is_action_just_pressed("NextPage"):
		next_page();
	elif Input.is_action_just_pressed("PrevPage"):
		prev_page();

func on_tab_pressed (index: int) -> void:
	_note_idx = index;
	load_note();
