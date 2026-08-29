extends Interactable
class_name Intercom

@export var tone: AudioStream
@export var dialogueSources : Array
@onready var dialogue = get_node("/root/Main/Dialogue")

var IsFirstTimeUse = true

func _on_activated() -> void:
	audio_player.stream = tone
	audio_player.play()

	if IsFirstTimeUse:
		dialogue.load_new_src(dialogueSources[0])

func _on_deactivated() -> void:
	pass
