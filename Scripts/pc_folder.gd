extends Button

@onready var cursor = $"../Cursor"

var folder_open := false # debounce

func _process(_delta: float) -> void:
	var cursor_pos: Vector2 = cursor.global_position

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if folder_open == false and get_global_rect().has_point(cursor_pos):
			folder_open = true
			print("folder open")
