extends Control

@onready var cursor = $Cursor
var mouse_pos : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_windows():
	var dialog = AcceptDialog.new()
	dialog.title = "Alert"
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.size = Vector2i(111, 84)
	dialog.dialog_hide_on_ok = true
	dialog.dialog_close_on_escape = true
	dialog.dialog_text = "Hello World"
	dialog.visible = true
	add_child(dialog)

func update_cursor_pos():
	cursor.position = mouse_pos
