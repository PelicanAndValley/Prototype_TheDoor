extends Control

class_name OpenableUI;

@export
var anim_tree : AnimationTree;
@export
var open_anim : StringName;
@export
var close_anim : StringName;

var _anim_playback : AnimationNodeStateMachinePlayback;
var _player : Player;
var _ui_state : DoorUI.OpenUI;

# To avoid having ready function overriden
func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		if anim_tree:
			_anim_playback = anim_tree["parameters/playback"];
			anim_tree.animation_finished.connect(self.animation_finished);

func open (ui_state: DoorUI.OpenUI) -> void:
	visible = true;
	if anim_tree:
		_player.open_ui = DoorUI.OpenUI.TRANSITION;
		_anim_playback.travel(open_anim);
		_ui_state = ui_state;
	else:
		_player.open_ui = ui_state;

func close () -> void:
	if anim_tree:
		_anim_playback.travel(close_anim);
		_player.open_ui = DoorUI.OpenUI.TRANSITION;
	else:
		visible = false;
		_player.open_ui = DoorUI.OpenUI.NONE;

func animation_finished (anim_name: StringName) -> void:
	if anim_name == close_anim:
		visible = false;
		if _player:
			_player.open_ui = DoorUI.OpenUI.NONE;
	elif anim_name == open_anim:
		# No safety check - if this is null, i wanna see the error
		_player.open_ui = _ui_state;
