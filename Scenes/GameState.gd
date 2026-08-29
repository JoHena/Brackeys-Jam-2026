extends Node3D

@onready var cinematic_camera: Camera3D = $CinematicCamera
@onready var menu_camera: Camera3D = $MenuCamera
@onready var camera_animator: AnimationPlayer = $CinematicCamera/AnimationPlayer

@onready var menu_control : Control = $Menu
@onready var dialogue : Control = $Dialogue
@onready var player: Player = $Player

var GameStarted = false
var StartPressed = false


func _ready() -> void:
	menu_camera.current = true

func _process(delta: float) -> void:
	if !StartPressed:
		if Input.is_action_just_pressed("ui_accept"):
			menu_control.visible = false

			var transitioner = get_node_or_null("/root/CameraTransition")
			if transitioner:
				await transitioner.switch_camera(func(): play_intro(), 1)
			
			StartPressed = true
			dialogue.fade_in()
			dialogue.timer.start(dialogue.time_to_advance)


func play_intro() -> void:
	player.capture_mouse()
	# Lock player input and start the cinematic
	player.is_animation_playing = true
	cinematic_camera.current = true
	camera_animator.play("Intro")
	await camera_animator.animation_finished

	# Glide the cinematic camera to match the player's camera exactly,
	# so switching cameras afterward is an invisible cut
	var player_camera = player.head.get_node("Camera3D")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cinematic_camera, "global_transform", player_camera.global_transform, 0.6)
	await tween.finished

	# Hand control back to the player
	player_camera.current = true
	player.is_animation_playing = false
	player.visible = true
	GameStarted = true
