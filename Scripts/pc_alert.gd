extends Control

@onready var cursor = $"../Cursor"
@onready var drag_bar: Control = $Panel/DragBar

var dragging := false
var drag_offset := Vector2.ZERO


func _process(_delta: float) -> void:
	var cursor_pos: Vector2 = cursor.global_position

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not dragging and drag_bar.get_global_rect().has_point(cursor_pos):
			dragging = true
			drag_offset = cursor_pos - global_position
	else:
		dragging = false

	if dragging:
		global_position = cursor_pos - drag_offset
