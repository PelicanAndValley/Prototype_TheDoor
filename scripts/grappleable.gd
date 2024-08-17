extends Area3D

class_name Grappleable;

signal hook_entered;

@export
var grapple_position : Node3D;
var thrown_hook : GrapplingHook;

func _ready() -> void:
	body_entered.connect(self.on_body_entered);

func on_body_entered (body: Node3D):
	if body == thrown_hook:
		hook_entered.emit();

func connect_hook (hook: GrapplingHook):
	thrown_hook = hook;
	hook_entered.connect(hook.on_hook_collided);
