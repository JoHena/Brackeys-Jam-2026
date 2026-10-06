extends Button

@onready var cursor = $"../Cursor"

func _process(_delta: float) -> void:
	var cursor_pos: Vector2 = cursor.global_position

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_global_rect().has_point(cursor_pos):
			print("folder open")
