extends StaticBody3D
class_name PCStatic

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var camera_3d : Camera3D = $Camera3D

var is_using: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func toogle_use():
	is_using =!is_using
	camera_3d.current = is_using

func _input(event: InputEvent) -> void:
	if !is_using:
		return
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_cancel"):
			toogle_use()
			player.IsInteracting = false;
			player.can_move = true;
