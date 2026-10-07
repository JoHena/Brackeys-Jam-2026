extends Button

@onready var cursor = $"../Cursor"

@onready var sub_window = $FolderWindow
@onready var close_button = $FolderWindow/Panel/CloseButton
@onready var drag_bar: Control = $FolderWindow/Panel/DragBar

var dragging := false
var drag_offset := Vector2.ZERO

var folder_open := false # debounce

func _process(_delta: float) -> void:
	var cursor_pos: Vector2 = cursor.global_position

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if folder_open == false and get_global_rect().has_point(cursor_pos):
			folder_open = true
			sub_window.visible = true
		elif folder_open == true:
			if not dragging and close_button.get_global_rect().has_point(cursor_pos) and cursor.dragged_window == null:
				folder_open = false
				sub_window.visible = false
			if not dragging and drag_bar.get_global_rect().has_point(cursor_pos) and cursor.dragged_window == null:
				dragging = true
				cursor.dragged_window = sub_window
				if cursor.prev_dragged_window != null:
					sub_window.z_index = cursor.prev_dragged_window.z_index + 1
				else:
					sub_window.z_index = 10
				if sub_window.z_index >= cursor.z_index:
					cursor.z_index *= 2
				drag_offset = cursor_pos - sub_window.global_position
	else:
		dragging = false
		if cursor.dragged_window == sub_window:
			cursor.prev_dragged_window = sub_window
			cursor.dragged_window = null
	
	if dragging:
		sub_window.global_position = cursor_pos - drag_offset
