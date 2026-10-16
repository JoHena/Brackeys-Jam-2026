
extends StaticBody3D
class_name Interactable

signal interaction_toggled(active: bool)
signal object_clicked(object: CollisionObject3D)

@export_group("Interaction")
@export var click_sfx: AudioStream = preload("res://SFX/mouse_click_1.ogg")
@export var transition_duration: float = 0.25

@export_group("Pointer")
@export var use_pointer: bool = true
@export var pointer_scene: PackedScene = preload("res://Scenes/Pointer.tscn")
@export var pointer_distance: float = 2.0
@export var pointer_bounds: Vector2 = Vector2(1.0, 0.6)
@export var pointer_sensitivity: float = 0.002
@export var pointer_sensitivity_scale: float = 0.5
@export var pointer_size: float = 0.01

@export_group("Interaction Raycast")
@export var interaction_distance: float = 10.0
@export_flags_3d_physics var interaction_mask: int = 1
@export var exclude_self_from_raycast: bool = true

@export_group("Highlight")
@export var highlight: InteractableHighlight

@onready var camera_3d: Camera3D = $InteractableCamera
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var player: Player
var is_using: bool = false
var is_transitioning: bool = false

var pointer: Sprite3D
var pointer_local_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player

	if player == null:
		push_error("%s: No node in group 'Player' found." % name)

	_setup_pointer()

	set_process_input(false)

	interaction_toggled.connect(_on_interaction_toggled)


# --------------------------------------------------
# Pointer Setup
# --------------------------------------------------

func _setup_pointer() -> void:
	if pointer != null or pointer_scene == null:
		return

	pointer = pointer_scene.instantiate() as Sprite3D

	if pointer == null:
		push_error("%s: Pointer scene must have a Sprite3D root." % name)
		return

	add_child(pointer)

	pointer.pixel_size = pointer_size
	pointer.no_depth_test = true
	pointer.visible = false


func set_pointer_enabled(enabled: bool) -> void:
	use_pointer = enabled

	if enabled and pointer == null:
		_setup_pointer()

	if pointer:
		pointer.visible = enabled and is_using

		if enabled and is_using:
			_reset_pointer_transform()


func _reset_pointer_transform() -> void:
	if pointer == null:
		return

	pointer_local_offset = Vector2.ZERO

	pointer.global_rotation = camera_3d.global_rotation
	pointer.global_position = _pointer_plane_position(
		pointer_local_offset
	)



func _update_pointer_position(event: InputEventMouseMotion) -> void:
	if pointer == null or not use_pointer:
		return

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var aspect_ratio: float = viewport_size.x / viewport_size.y

	var visible_height: float
	var visible_width: float

	if camera_3d.keep_aspect == Camera3D.KEEP_HEIGHT:
		visible_height = camera_3d.size
		visible_width = visible_height * aspect_ratio
	else:
		visible_width = camera_3d.size
		visible_height = visible_width / aspect_ratio

	pointer_local_offset.x += (
		event.relative.x / viewport_size.x
	) * visible_width * pointer_sensitivity_scale

	pointer_local_offset.y -= (
		event.relative.y / viewport_size.y
	) * visible_height * pointer_sensitivity_scale

	pointer_local_offset.x = clampf(
		pointer_local_offset.x,
		-visible_width * 0.5,
		visible_width * 0.5
	)

	pointer_local_offset.y = clampf(
		pointer_local_offset.y,
		-visible_height * 0.5,
		visible_height * 0.5
	)

	pointer.global_position = _pointer_plane_position(
		pointer_local_offset
	)

	pointer.global_rotation = camera_3d.global_rotation


func _pointer_plane_position(offset: Vector2) -> Vector3:
	var basis: Basis = camera_3d.global_transform.basis

	return (
		camera_3d.global_position
		- basis.z * pointer_distance
		+ basis.x * offset.x
		+ basis.y * offset.y
	)


# --------------------------------------------------
# Camera / Interaction State
# --------------------------------------------------

func toggle_use() -> void:
	if is_transitioning or player == null:
		return

	is_transitioning = true

	var going_active: bool = not is_using

	var transitioner: Node = get_node_or_null(
		"/root/CameraTransition"
	)

	if transitioner:
		await transitioner.switch_camera(
			func() -> void:
				_apply_use_state(going_active),
			transition_duration
		)
	else:
		_apply_use_state(going_active)

	is_transitioning = false


func _apply_use_state(active: bool) -> void:
	is_using = active

	if active:
		camera_3d.current = true
	else:
		player.activate_camera()

	player.visible = not active

	set_process_input(active)

	if pointer:
		pointer.visible = active and use_pointer

		if active:
			_reset_pointer_transform()

	if active:
		_on_activated()
	else:
		_on_deactivated()

	interaction_toggled.emit(active)


func _on_interaction_toggled(active: bool) -> void:
	if player == null:
		return

	player.is_interacting = active
	player.can_move = not active


# --------------------------------------------------
# 3D Object Detection
# --------------------------------------------------


func get_clicked_object() -> CollisionObject3D:
	var screen_position: Vector2

	if use_pointer and pointer != null:
		screen_position = camera_3d.unproject_position(
			pointer.global_position
		)
	else:
		screen_position = get_viewport().get_visible_rect().size * 0.5

	var origin: Vector3 = camera_3d.project_ray_origin(
		screen_position
	)

	var direction: Vector3 = camera_3d.project_ray_normal(
		screen_position
	)

	var end: Vector3 = origin + direction * interaction_distance

	var query := PhysicsRayQueryParameters3D.create(
		origin,
		end,
		interaction_mask
	)

	query.collide_with_areas = true
	query.collide_with_bodies = true

	var excluded: Array[RID] = [get_rid()]

	if player != null:
		excluded.append(player.get_rid())

	query.exclude = excluded

	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return null

	var collider: CollisionObject3D = result["collider"] as CollisionObject3D

	print("Pointer screen: ", screen_position)
	print("Ray hit: ", collider.name)
	print("Hit position: ", result["position"])

	return collider

# --------------------------------------------------
# Input
# --------------------------------------------------

func _input(event: InputEvent) -> void:
	if not is_using or is_transitioning:
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		toggle_use()
		return

	if event is InputEventMouseMotion:
		_update_pointer_position(event)

	if event.is_action_pressed("Interact"):
		if event.is_echo():
			return

		_play_click_sfx()
		_on_interact_input(event)

		get_viewport().set_input_as_handled()
	else:
		_on_other_input(event)


# --------------------------------------------------
# Audio
# --------------------------------------------------

func _play_click_sfx() -> void:
	if audio_player == null or click_sfx == null:
		return

	audio_player.stream = click_sfx
	audio_player.play()


# --------------------------------------------------
# Highlight
# --------------------------------------------------

func set_glow(enabled: bool) -> void:
	if highlight:
		highlight.set_highlight(enabled)


# --------------------------------------------------
# Virtual Hooks
# --------------------------------------------------

func _on_activated() -> void:
	pass


func _on_deactivated() -> void:
	pass


func _on_interact_input(_event: InputEvent) -> void:
	pass


func _on_other_input(_event: InputEvent) -> void:
	pass
