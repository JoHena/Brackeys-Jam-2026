extends Interactable
class_name ElectricalPuzzle

func _on_activated() -> void:
	pass

func _on_deactivated() -> void:
	pass

func _on_interact_input(_event: InputEvent) -> void:
	var clicked_object: CollisionObject3D = get_clicked_object()

	if clicked_object == null:
		return

	var node: Node = clicked_object

	while node != null:
		if node is Circuit_Piece:
			var circuit_piece: Circuit_Piece = node as Circuit_Piece

			circuit_piece.on_clicked()
			return

		node = node.get_parent()
