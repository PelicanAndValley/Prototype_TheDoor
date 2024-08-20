extends Area3D

class_name Grappleable;

signal hook_entered;

@export
var grapple_position : Node3D;
@export
var grapple_area : Node3D;
var thrown_hook : GrapplingHook;

func _ready() -> void:
	area_entered.connect(self.on_area_entered);

func on_area_entered (area: Area3D):
	if area == thrown_hook:
		hook_entered.emit();
		call_deferred("disable");

func connect_hook (hook: GrapplingHook):
	thrown_hook = hook;
	hook_entered.connect(hook.on_hook_collided);

func disable () -> void:
	grapple_area.process_mode = Node.PROCESS_MODE_DISABLED;
