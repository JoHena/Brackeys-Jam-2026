extends Interactable
class_name PCStatic
## The in-world PC: forwards clicks into the SubViewport and drives a
## virtual mouse cursor while the player is using it.

@onready var sub_viewport: SubViewport = $SubViewport
@onready var pc_controller: Control = $SubViewport/PCControl


func _on_activated() -> void:
	# Reset the virtual cursor to the center when opening the screen so it
	# doesn't spawn wherever it was last left.
	pc_controller.mouse_pos = sub_viewport.size / 2.0
	pc_controller.update_cursor_pos()


func _on_interact_input(event: InputEvent) -> void:
	sub_viewport.push_input(event)


func _on_other_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pc_controller.mouse_pos += event.relative
		pc_controller.mouse_pos = pc_controller.mouse_pos.clamp(
			Vector2.ZERO,
			sub_viewport.size - Vector2i(10, 10)
		)
		pc_controller.update_cursor_pos()
