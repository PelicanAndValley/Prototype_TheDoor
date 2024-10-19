extends Interactable

class_name Chain;

var _anim_playback : AnimationNodeStateMachinePlayback;
var _anim_tree : AnimationTree;
var _dynamite : PlacedDynamite;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim_tree = $AnimationTree;
	_anim_playback = _anim_tree["parameters/playback"];

func add_dynamite(dynamite: PlacedDynamite):
	_dynamite = dynamite;
	add_child(_dynamite);

func detonate_dynamite():
	_dynamite.trigger();

func _on_interact(player: Variant, point: Variant) -> void:
	_anim_playback.travel("ChainExplodeSequence");
