extends Control

class_name DoorUI;

enum OpenUI { NONE, TRANSITION, NOTEBOOK, MENU };
var open_ui = OpenUI.NONE;

@export
var notebook : OpenableUI;
@export
var menu : OpenableUI;

var _player : Player;

func set_player (player: Player):
	_player = player;
	notebook._player = player;
	menu._player = player;

func _process (delta: float) -> void:
	
	# Notebook
	if Input.is_action_just_pressed("Notebook"):
		if open_ui == OpenUI.NONE:
			notebook.open(OpenUI.NOTEBOOK);
			open_ui = OpenUI.NOTEBOOK;
			_player.release_mouse();
		elif open_ui == OpenUI.NOTEBOOK:
			notebook.close();
			open_ui = OpenUI.NONE;
			_player.capture_mouse();
	
	if Input.is_action_just_pressed("Escape"):
		if open_ui == OpenUI.NONE:
			menu.open(OpenUI.MENU);
			open_ui = OpenUI.MENU;
			get_tree().paused = true;
			_player.release_mouse();
		else:
			get_tree().paused = false;
			close_all_ui();

func open_notebook () -> void:
	if open_ui == OpenUI.NOTEBOOK:
		return;
	if open_ui != OpenUI.NONE:
		close_all_ui();
	open_ui = OpenUI.NOTEBOOK;
	notebook.open(OpenUI.NOTEBOOK);
	_player.release_mouse()

func close_all_ui () -> void:
	open_ui = OpenUI.NONE;
	notebook.close();
	menu.close();
	_player.capture_mouse();
