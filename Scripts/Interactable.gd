extends StaticBody3D
class_name Interactable
## Base class for anything the player can walk up to, "use", and get locked
## into a dedicated camera view for (PC, intercom, etc).
##
## Handles:
##   - swapping to this object's Camera3D while in use
##   - toggling player movement/interaction state
##   - the common ui_cancel-to-exit and Interact-click flow
##   - playing the click SFX
##
## Subclasses hook into the flow via the virtual _on_* methods below rather
## than overriding _input/toggle_use directly.

## Emitted whenever the interactable is turned on/off, so external systems
## (like the Player) can react without this class needing to know their
## internals.
signal interaction_toggled(active: bool)

@export var click_sfx: AudioStream = preload("res://SFX/blip.ogg")
@onready var camera_3d: Camera3D = $Camera3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var player: Player
var is_using: bool = false


func _ready() -> void:
	# Cache the player reference once; warn loudly if it's missing instead
	# of crashing later inside toggle_use().
	player = get_tree().get_first_node_in_group("Player") as Player
	if player == null:
		push_error("%s: no node in group 'Player' found." % name)

	# Only listen for input while actually being used.
	set_process_input(false)
	interaction_toggled.connect(_on_interaction_toggled)


func toggle_use() -> void:
	is_using = !is_using
	camera_3d.current = is_using
	set_process_input(is_using)

	if is_using:
		_on_activated()
	else:
		_on_deactivated()

	interaction_toggled.emit(is_using)


func _on_interaction_toggled(active: bool) -> void:
	if player == null:
		return
	player.IsInteracting = active
	player.can_move = !active


func _input(event: InputEvent) -> void:
	if not is_using:
		return

	if event.is_action_pressed("ui_cancel"):
		toggle_use()
		get_viewport().set_input_as_handled()
		return

	if Input.is_action_just_pressed("Interact"):
		_play_click_sfx()
		_on_interact_input(event)
	else:
		_on_other_input(event)


func _play_click_sfx() -> void:
	audio_player.stream = click_sfx
	audio_player.play()


## --- Virtual hooks for subclasses -----------------------------------------

## Called right after is_using becomes true (before the signal fires).
## Override for setup like resetting a cursor or starting a call tone.
func _on_activated() -> void:
	pass


## Called right after is_using becomes false (before the signal fires).
## Override for teardown.
func _on_deactivated() -> void:
	pass


## Called when the "Interact" action is pressed while in use, right after
## the click SFX plays. Override to forward the click (e.g. into a
## SubViewport).
func _on_interact_input(event: InputEvent) -> void:
	pass


## Called for any input while in use that isn't ui_cancel or an Interact
## press (e.g. mouse motion). Override for things like cursor dragging.
func _on_other_input(event: InputEvent) -> void:
	pass
