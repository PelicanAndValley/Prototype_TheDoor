extends Node3D

class_name PlacedDynamite;

@export
var explosion_effect : Effect;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func trigger () -> void:
	explosion_effect.trigger();
	$DynamiteModel.queue_free();
	
