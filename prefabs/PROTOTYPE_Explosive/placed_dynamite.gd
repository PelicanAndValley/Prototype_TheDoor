extends Node3D

class_name PlacedDynamite;

@export
var explosion_effect : PackedScene;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func trigger () -> void:
	var placed_explosion : Node3D = explosion_effect.instantiate();
	self.add_child(placed_explosion);
	placed_explosion.global_position = global_position;
	$DynamiteModel.queue_free();
