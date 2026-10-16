
@tool
extends Node3D
class_name CircuitAssigner

const CIRCUIT_SCENES: Array[PackedScene] = [
	preload("res://Scenes/Puzzles/CircuitPuzzle/Pieces/L_Piece.tscn"),
	preload("res://Scenes/Puzzles/CircuitPuzzle/Pieces/I_Piece.tscn"),
	preload("res://Scenes/Puzzles/CircuitPuzzle/Pieces/T_Piece.tscn"),
	preload("res://Scenes/Puzzles/CircuitPuzzle/Pieces/U_Piece.tscn")
]

@export var columns: Array[CircuitColumn] = []:
	set(value):
		columns = value
		update_pieces()


@export_tool_button("Sync Columns")
var sync_button: Callable = sync_columns


func sync_columns() -> void:
	var column_count := 0

	for child in get_children():
		if child is Node3D and child.name.begins_with("Column"):
			column_count += 1

	var new_columns: Array[CircuitColumn] = columns.duplicate()

	while new_columns.size() < column_count:
		new_columns.append(CircuitColumn.new())

	while new_columns.size() > column_count:
		new_columns.remove_at(new_columns.size() - 1)

	columns = new_columns

	notify_property_list_changed()
	update_pieces()

	print("Synced columns: ", columns.size())


func _ready() -> void:
	update_pieces()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_pieces()


func get_circuit_scene(
	type: CircuitPiece.CircuitType
) -> PackedScene:
	var index := int(type)

	if index < 0 or index >= CIRCUIT_SCENES.size():
		return null

	return CIRCUIT_SCENES[index]


func update_pieces() -> void:
	var column_nodes: Array[Node3D] = []

	for child in get_children():
		if child is Node3D and child.name.begins_with("Column"):
			column_nodes.append(child)

	for column_index in range(
		min(columns.size(), column_nodes.size())
	):
		var column_data := columns[column_index]

		if column_data == null:
			continue

		var column_node := column_nodes[column_index]
		var pieces: Array[Node3D] = []

		for child in column_node.get_children():
			if child is Node3D and child.name.begins_with("Piece"):
				pieces.append(child)

		for piece_index in range(
			min(column_data.pieces.size(), pieces.size())
		):
			var piece_data := column_data.pieces[piece_index]

			if piece_data == null:
				continue

			var piece_node := pieces[piece_index]
			var selected_scene := get_circuit_scene(
				piece_data.type
			)

			if selected_scene == null:
				continue

			update_piece_scene(
				piece_node,
				selected_scene,
				float(piece_data.rotation)
			)


func update_piece_scene(
	piece_node: Node3D,
	selected_scene: PackedScene,
	rotation_value: float
) -> void:
	var scene_instance: Node3D = null

	for child in piece_node.get_children():
		if child is Node3D and child.has_meta(
			"circuit_scene"
		):
			scene_instance = child
			break

	var scene_path := selected_scene.resource_path

	if scene_instance != null:
		var current_path: String = scene_instance.get_meta(
			"circuit_scene", ""
		)

		if current_path != scene_path:
			piece_node.remove_child(scene_instance)
			scene_instance.free()
			scene_instance = null

	if scene_instance == null:
		scene_instance = selected_scene.instantiate() as Node3D

		if scene_instance == null:
			return

		scene_instance.name = "CircuitScene"
		scene_instance.set_meta(
			"circuit_scene",
			scene_path
		)

		piece_node.add_child(scene_instance)

		if Engine.is_editor_hint():
			scene_instance.owner = get_tree().edited_scene_root

	if not is_equal_approx(
		scene_instance.rotation_degrees.z,
		rotation_value
	):
		scene_instance.rotation_degrees.z = rotation_value
