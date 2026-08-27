extends StaticBody3D
class_name Interactable
## Base class for anything the player can walk up to, "use", and get locked
## into a dedicated camera view for (PC, intercom, etc).
##
## Handles:
##   - swapping to this object's Camera3D while in use
##   - toggling player movement/interaction state
##   - the common ui_cancel-to-exit and Interact-click flow
##   - playing the click SFX
##
## Subclasses hook into the flow via the virtual _on_* methods below rather
## than overriding _input/toggle_use directly.

## Emitted whenever the interactable is turned on/off, so external systems
## (like the Player) can react without this class needing to know their
## internals.
signal interaction_toggled(active: bool)

@export var click_sfx: AudioStream = preload("res://SFX/mouse_click_1.ogg")

@export_group("Pointer")
## Turn off for interactables that already have their own cursor (e.g. the
## PC's SubViewport/Control cursor) and don't need a 3D reticle too.
@export var use_pointer: bool = true
## Scene for the on-screen pointer/reticle. Leave assigned even if
## use_pointer starts false — flip use_pointer at runtime to enable it.
@export var pointer_scene: PackedScene = preload("res://Scenes/Pointer.tscn")
## How far in front of camera_3d the pointer sits.
@export var pointer_distance: float = 2.0
## Half-width/half-height (in world units, at pointer_distance) of the
## flat plane the pointer is allowed to move within.
@export var pointer_bounds: Vector2 = Vector2(1.0, 0.6)
## World units the pointer moves per pixel of mouse motion.
@export var pointer_sensitivity: float = 0.002

@onready var camera_3d: Camera3D = $InteractableCamera
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var player: Player
var is_using: bool = false
var pointer: Sprite3D
var pointer_local_offset: Vector2


func _ready() -> void:
	# Cache the player reference once; warn loudly if it's missing instead
	# of crashing later inside toggle_use().
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		push_error("%s: no node in group 'Player' found." % name)

	if use_pointer and pointer_scene:
		pointer = pointer_scene.instantiate()
		add_child(pointer)
		pointer.no_depth_test = true
		pointer.visible = false

	# Only listen for input while actually being used.
	set_process_input(false)
	interaction_toggled.connect(_on_interaction_toggled)


func toggle_use() -> void:
	is_using = !is_using
	camera_3d.current = is_using
	set_process_input(is_using)

	if pointer:
		pointer.visible = is_using and use_pointer
		if is_using:
			_reset_pointer_transform()

	if is_using:
		_on_activated()
	else:
		_on_deactivated()

	interaction_toggled.emit(is_using)


## Snaps the pointer to camera_3d's rotation, centered on the flat plane
## pointer_distance in front of it — so it starts centered instead of
## wherever it was left (or the origin) before the first mouse-motion
## event moves it.
func _reset_pointer_transform() -> void:
	if pointer == null:
		return
	pointer_local_offset = Vector2.ZERO
	pointer.global_rotation = camera_3d.global_rotation
	pointer.global_position = _pointer_plane_position(pointer_local_offset)


func _update_pointer_position(event: InputEventMouseMotion) -> void:
	if pointer == null or not use_pointer:
		return
	# Move linearly along the camera's own right/up axes rather than going
	# through perspective unprojection — keeps the pointer confined to a
	# flat plane fixed in front of the camera, so it moves like a 2D
	# cursor regardless of FOV or viewport size. event.relative is used
	# (not event.position) since position freezes in MOUSE_MODE_CAPTURED.
	pointer_local_offset.x += event.relative.x * pointer_sensitivity
	pointer_local_offset.y -= event.relative.y * pointer_sensitivity
	pointer.global_position = _pointer_plane_position(pointer_local_offset)
	pointer.global_rotation = camera_3d.global_rotation


## Converts a local (x = right, y = up) offset into a world position on
## the flat plane pointer_distance in front of camera_3d.
func _pointer_plane_position(offset: Vector2) -> Vector3:
	var basis := camera_3d.global_transform.basis
	return camera_3d.global_position \
		- basis.z * pointer_distance \
		+ basis.x * offset.x \
		+ basis.y * offset.y


func _on_interaction_toggled(active: bool) -> void:
	if player == null:
		return
	player.IsInteracting = active
	player.can_move = !active


func _input(event: InputEvent) -> void:
	if not is_using:
		return

	if event.is_action_pressed("ui_cancel"):
		toggle_use()
		get_viewport().set_input_as_handled()
		return

	if Input.is_action_just_pressed("Interact"):
		_play_click_sfx()
		_on_interact_input(event)
	else:
		_on_other_input(event)

	if event is InputEventMouseMotion:
		_update_pointer_position(event)


func _play_click_sfx() -> void:
	audio_player.stream = click_sfx
	audio_player.play()


## --- Virtual hooks for subclasses -----------------------------------------

## Called right after is_using becomes true (before the signal fires).
## Override for setup like resetting a cursor or starting a call tone.
func _on_activated() -> void:
	pass


## Called right after is_using becomes false (before the signal fires).
## Override for teardown.
func _on_deactivated() -> void:
	pass


## Called when the "Interact" action is pressed while in use, right after
## the click SFX plays. Override to forward the click (e.g. into a
## SubViewport).
func _on_interact_input(event: InputEvent) -> void:
	pass


## Called for any input while in use that isn't ui_cancel or an Interact
## press (e.g. mouse motion). Override for things like cursor dragging.
func _on_other_input(event: InputEvent) -> void:
	pass
