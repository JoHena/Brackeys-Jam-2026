@tool
extends Node3D
class_name Circuit_Piece


@export_group("Circuit")
@export var IsActive: bool = false:
	set(value):
		if IsActive == value:
			return

		IsActive = value

		if is_node_ready():
			update_visuals()

@export var IsPowerSource: bool = false:
	set(value):
		if IsPowerSource == value:
			return

		IsPowerSource = value

		if is_node_ready():
			request_recalculation()

@export var IsLocked: bool = false
@export var IsEndingNode: bool = false

@onready var omni_light: OmniLight3D = get_node_or_null("OmniLight3D")


@export_group("Emission")
@export var emission_color: Color = Color.SKY_BLUE:
	set(value):
		emission_color = value

		if is_node_ready():
			update_visuals()


@export var emission_energy: float = 3.0:
	set(value):
		emission_energy = value

		if is_node_ready():
			update_visuals()


@export_group("Animation")
@export var fade_in_duration: float = 0.35
@export var fade_out_duration: float = 0.5


@export_tool_button("Refresh Circuit")
var refresh_button: Callable = request_recalculation


var _materials: Array[StandardMaterial3D] = []
var _refresh_queued: bool = false

var _emission_tween: Tween
var _current_energy: float = 0.0
var _original_light_energy: float = 0.0

# Rotation
var _rotation_tween: Tween
var _target_rotation: float = 0.0
var _is_rotating: bool = false

# Signals
signal powered_up(piece: Circuit_Piece)
signal powered_down(piece: Circuit_Piece)


# --------------------------------------------------
# READY
# --------------------------------------------------

func _ready() -> void:
	add_to_group("circuit_pieces")

	_target_rotation = rotation.z

	_setup_connections()
	_setup_materials()

	# Store the light's Inspector energy.
	if is_instance_valid(omni_light):
		_original_light_energy = omni_light.light_energy

	_current_energy = emission_energy if IsActive else 0.0
	_apply_emission(_current_energy)

	request_recalculation()


# --------------------------------------------------
# ROTATION
# --------------------------------------------------

func on_clicked() -> void:
	if IsLocked or _is_rotating:
		return

	if Engine.is_editor_hint():
		return

	_is_rotating = true
	_target_rotation += deg_to_rad(90.0)

	_rotation_tween = create_tween()
	_rotation_tween.set_trans(Tween.TRANS_CUBIC)
	_rotation_tween.set_ease(Tween.EASE_OUT)

	_rotation_tween.tween_property(
		self,
		"rotation:z",
		_target_rotation,
		0.25
	)

	await _rotation_tween.finished

	_is_rotating = false
	request_recalculation()


# --------------------------------------------------
# CONNECTIONS
# --------------------------------------------------

func _setup_connections() -> void:
	for node in find_children("*", "Area3D", true, false):
		var connection := node as Area3D

		if not connection.area_entered.is_connected(
			_on_adjecents_area_entered
		):
			connection.area_entered.connect(
				_on_adjecents_area_entered
			)

		if not connection.area_exited.is_connected(
			_on_adjecents_area_exited
		):
			connection.area_exited.connect(
				_on_adjecents_area_exited
			)


# --------------------------------------------------
# SPRITE MATERIAL SETUP
# --------------------------------------------------

func _setup_materials() -> void:
	_materials.clear()

	for node in find_children("*", "Sprite3D", true, false):
		var sprite := node as Sprite3D

		var material: StandardMaterial3D

		if sprite.material_override is StandardMaterial3D:
			material = (
				sprite.material_override.duplicate()
				as StandardMaterial3D
			)
		else:
			material = StandardMaterial3D.new()

		material.emission_enabled = true
		material.emission = emission_color
		material.emission_operator = BaseMaterial3D.EMISSION_OP_ADD

		sprite.material_override = material
		_materials.append(material)


# --------------------------------------------------
# ACTIVE STATE
# --------------------------------------------------

func set_active(value: bool) -> void:
	if IsActive == value:
		return

	IsActive = value

	if not IsEndingNode:
		return

	if Engine.is_editor_hint():
		return

	if IsActive:
		on_powered_up()
		powered_up.emit(self)
	else:
		on_powered_down()
		powered_down.emit(self)

func on_powered_up() -> void:
	print("Ending node powered: ", name)

func on_powered_down() -> void:
	print("Ending node lost power: ", name)

# --------------------------------------------------
# EMISSION ANIMATION
# --------------------------------------------------

func update_visuals() -> void:
	if not is_node_ready():
		return

	if is_instance_valid(_emission_tween):
		_emission_tween.kill()

	var target_energy: float = (
		emission_energy if IsActive else 0.0
	)

	var duration: float = (
		fade_in_duration if IsActive else fade_out_duration
	)

	if Engine.is_editor_hint() or duration <= 0.0:
		_apply_emission(target_energy)
		return

	_emission_tween = create_tween()
	_emission_tween.set_trans(Tween.TRANS_SINE)
	_emission_tween.set_ease(Tween.EASE_IN_OUT)

	_emission_tween.tween_method(
		_apply_emission,
		_current_energy,
		target_energy,
		duration
	)


func _apply_emission(energy: float) -> void:
	_current_energy = energy

	# Update Sprite3D emission.
	for material in _materials:
		if not is_instance_valid(material):
			continue

		material.emission_enabled = true
		material.emission = emission_color
		material.emission_energy_multiplier = energy

	# Preserve light Inspector values in editor.
	if Engine.is_editor_hint():
		return

	# Fade OmniLight3D with emission.
	if is_instance_valid(omni_light):
		var intensity: float = clampf(
			energy / maxf(emission_energy, 0.001),
			0.0,
			1.0
		)

		omni_light.light_energy = (
			_original_light_energy * intensity
		)

		omni_light.light_color = emission_color
		omni_light.visible = intensity > 0.001


# --------------------------------------------------
# CONNECTION SIGNALS
# --------------------------------------------------

func _on_adjecents_area_entered(_area: Area3D) -> void:
	if _is_rotating:
		return

	request_recalculation()


func _on_adjecents_area_exited(_area: Area3D) -> void:
	if _is_rotating:
		return

	request_recalculation()


# --------------------------------------------------
# NETWORK RECALCULATION
# --------------------------------------------------

func request_recalculation() -> void:
	if not is_node_ready() or _refresh_queued:
		return

	if _is_rotating:
		return

	_refresh_queued = true
	call_deferred("_refresh_network")


func _refresh_network() -> void:
	_refresh_queued = false

	if not is_node_ready():
		return

	if _is_rotating:
		return

	recalculate_network()


# --------------------------------------------------
# CONNECTED PIECES
# --------------------------------------------------

func get_connected_pieces() -> Array[Circuit_Piece]:
	var connected: Array[Circuit_Piece] = []

	for node in find_children("*", "Area3D", true, false):
		var connection := node as Area3D

		for area in connection.get_overlapping_areas():
			var other := find_piece_owner(area)

			if other == null or other == self:
				continue

			if not connected.has(other):
				connected.append(other)

	return connected


func find_piece_owner(node: Node) -> Circuit_Piece:
	var current: Node = node

	while current != null:
		if current is Circuit_Piece:
			return current as Circuit_Piece

		current = current.get_parent()

	return null


# --------------------------------------------------
# POWER PROPAGATION
# --------------------------------------------------

func recalculate_network() -> void:
	var all_pieces: Array[Node] = get_tree().get_nodes_in_group(
		"circuit_pieces"
	)

	var visited: Dictionary = {}
	var queue: Array[Circuit_Piece] = []

	# Find power sources.
	for node in all_pieces:
		var piece := node as Circuit_Piece

		if piece == null:
			continue

		if piece.IsPowerSource:
			queue.append(piece)
			visited[piece] = true

	# Traverse connected pieces.
	while not queue.is_empty():
		var current: Circuit_Piece = queue.pop_front()

		for neighbor in current.get_connected_pieces():
			if visited.has(neighbor):
				continue

			visited[neighbor] = true
			queue.append(neighbor)

	# Update active states.
	for node in all_pieces:
		var piece := node as Circuit_Piece

		if piece != null:
			piece.set_active(visited.has(piece))
