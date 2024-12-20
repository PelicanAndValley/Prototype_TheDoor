extends Interactable;

class_name Key;

@export
var balloon : Node3D;
@export
var balloon_rope : Node3D;
@export
var _rope_pos : Node3D;
@export
var anim_tree : AnimationTree;
@export
var key_turn_model : Node3D;
@export
var key_turn_anim : AnimationTree;
@export
var sound : AudioStreamPlayer3D;
@export
var rope_sound : AudioStreamPlayer3D;
@export
var turn_sound : AudioStreamPlayer3D;
@export
var _player : Player;
@export
var _door : Door;
@export
var my_daddy : Node3D;
@export
var dust_effect : Effect;
@export
var dust_delay : float = 5500;
var dust_start : float = 0;

var _anim_playback : AnimationNodeStateMachinePlayback;
var _velocity : Vector3;

var has_balloon : bool = false;
var has_rope : bool = false;
var can_move : bool = false;
@export
var speed : float;
@export
var acceleration : float;

var _in_place : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim_playback = anim_tree["parameters/playback"];
	balloon.process_mode = Node.PROCESS_MODE_DISABLED;
	balloon.visible = false;
	balloon_rope.visible = false;

func dislodge () -> void:
	sound.play();
	rope_sound.play();
	_anim_playback.travel("Rise");
	has_balloon = true;
	balloon.process_mode = Node.PROCESS_MODE_INHERIT;
	balloon.visible = true;
	balloon_rope.visible = true;
	dust_start = Time.get_ticks_msec();

func _process(delta: float) -> void:
	if dust_start > 0 and Time.get_ticks_msec() - dust_start >= dust_delay:
		dust_effect.trigger();
		dust_start = 0;

func put_in_lock () -> void:
	turn_sound.play();
	$KeyModel.visible = false;
	key_turn_model.visible = true;
	key_turn_anim["parameters/playback"].travel("Animation");
	
func anim_finished (anim_name: StringName) -> void:
	if anim_name == "Animation":
		_player.final_cam.make_current();
		_player.final_stuff.visible = true;
		_player.end_screen.visible = true;
		_player.end_screen.start();
		_door.open(_player);
		my_daddy.reparent(_door.left);
		
