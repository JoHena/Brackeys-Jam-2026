extends Control
@export_file("*.json") var jsonsrc
var scene_script : Dictionary
var current_block : Dictionary
var next_block : Dictionary

@export_category("Control references")
@export var char_text : RichTextLabel
@export var char_name : Label

@export_category("AutoPlay")
@export var time_to_advance = 2.0
@export var timer: Timer
@export var fade_duration = 0.5

@onready var game_manager = get_node("/root/Main")
@onready var audio_stream = $DialoguePlayer

func _ready() -> void:
	load_new_src(jsonsrc)

func load_new_src(src: String):
	modulate.a = 0.0
	get_json(src)
	load_block(current_block)

func get_json(src: String):
	var jsontext = FileAccess.get_file_as_string(src)
	scene_script = JSON.parse_string(jsontext)
	current_block = scene_script["Start"]

func load_block(block : Dictionary):
	if game_manager.GameStarted:
		fade_in()
		timer.start(time_to_advance)

	if block.has("src"):
		audio_stream.stream = load("res://SFX/" + block["src"])
		audio_stream.pitch_scale = randf_range(0.5, 0.7)
		audio_stream.play()

	if block.has("text"): char_text.text = block["text"]

	if block.has("next"):
		var key = block["next"]
		next_block = scene_script[key]

func next():
	current_block = next_block
	load_block(current_block)

func _input(event: InputEvent) -> void:
	if !game_manager.GameStarted: return

	if event.is_action_pressed("ui_accept"):
		if current_block.has("next"):
			next()

func _on_timer_timeout() -> void:
	if current_block.has("next"):
		next()
	else:
		fade_out()
		timer.stop()

func fade_in() -> void:
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await tween.finished
	visible = false
