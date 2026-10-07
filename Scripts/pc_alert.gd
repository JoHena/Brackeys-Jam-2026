extends Control

@onready var cursor = $"../Cursor"
@onready var drag_bar: Control = $Panel/DragBar
@onready var orig_index := z_index

var dragging := false
var drag_offset := Vector2.ZERO



func _process(_delta: float) -> void:
	var cursor_pos: Vector2 = cursor.global_position

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not dragging and drag_bar.get_global_rect().has_point(cursor_pos) and cursor.dragged_window == null:
			dragging = true
			cursor.dragged_window = self
			z_index = 99
			drag_offset = cursor_pos - global_position
	else:
		dragging = false
		z_index = orig_index
		if cursor.dragged_window == self:
			cursor.dragged_window = null

	if dragging:
		global_position = cursor_pos - drag_offset
