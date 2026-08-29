# ProtoController v1.0 by Brackeys (refactored)
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

class_name Player

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "Left"
## Name of Input Action to move Right.
@export var input_right : String = "Right"
## Name of Input Action to move Forward.
@export var input_forward : String = "Up"
## Name of Input Action to move Backward.
@export var input_back : String = "Down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

@export_group("Footsteps")
@export var footstep_sfx : AudioStream = preload("res://SFX/footstep.ogg")
@export var footstep_interval : float = 0.2

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var footstep_cooldown : float = 0.0

## Renamed from IsInteracting/IsAnimationPlaying to match GDScript's
## snake_case member convention (PascalCase is reserved for class names).
## Interactable.gd and any cutscene script must use these new names.
var is_interacting : bool = false
var is_animation_playing : bool = true


## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var shape_cast_3d : ShapeCast3D = $Head/Camera3D/ShapeCast3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var pointer = $Head/Camera3D/Dot


func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x


## Convenience for cutscenes/callers who don't want to know the node path
## (e.g. `await CameraTransition.switch_camera(player.activate_camera)`).
func activate_camera() -> void:
	camera_3d.current = true


func _input(event: InputEvent) -> void:
	if is_animation_playing:
		return

	# Works for any Interactable subclass (PC, intercom, etc) instead of
	# hardcoding a single type. is_interacting/can_move don't need to be
	# set here anymore — Interactable._on_interaction_toggled already
	# syncs both of those on this Player whenever toggle_use() fires its
	# signal.
	if is_interacting:
		pointer.visible = false
		return

	if Input.is_action_just_pressed("Interact"):
		if shape_cast_3d.is_colliding():
			var collided = shape_cast_3d.get_collision_result()[0]["collider"]
			if collided is Interactable:
				collided.toggle_use()


func _unhandled_input(event: InputEvent) -> void:
	if is_animation_playing:
		return

	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()

	# Look around
	if not is_interacting:
		pointer.visible = true
		if mouse_captured and event is InputEventMouseMotion:
			rotate_look(event.relative)

	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()


func _physics_process(delta: float) -> void:
	if is_animation_playing:
		return

	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return

	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move and not is_interacting:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
			_process_footsteps(delta)
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
			footstep_cooldown = 0.0
	else:
		velocity.x = 0
		velocity.y = 0

	# Use velocity to actually move
	move_and_slide()


## Was previously using get_process_delta_time() (the _process delta)
## inside _physics_process, which drifts from the physics delta — now
## takes the same delta the physics step is already using. Also no longer
## reloads the footstep sound from disk on every step.
func _process_footsteps(delta: float) -> void:
	footstep_cooldown -= delta
	if footstep_cooldown <= 0.0:
		audio_player.stream = footstep_sfx
		audio_player.play()
		footstep_cooldown = footstep_interval


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO


func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
