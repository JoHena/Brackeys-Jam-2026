extends CanvasLayer

## Provides a single reusable way to hide a camera cut behind a fade,
## so the intro cutscene, Interactables (PC, intercom, etc), and anything
## else that swaps `Camera3D.current` don't each need their own ColorRect
## and tween boilerplate.
##

## Usage:
##   await CameraTransition.switch_camera(func(): my_camera.current = true)

@export var fade_color: Color = Color.BLACK
@export var default_duration: float = 0.25

var _fade_rect: ColorRect
var _busy: bool = false


func _ready() -> void:
	# Without this, pausing the tree (get_tree().paused = true) mid-fade
	# stalls these tweens forever — _busy never resets to false, and every
	# transition after that point gets silently swallowed by the _busy
	# guard in switch_camera(). Fades need to run through pause regardless.
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100 # draw above everything else
	_fade_rect = ColorRect.new()
	_fade_rect.color = fade_color
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade_rect)


## Fades out, invokes on_switch (do your camera.current = true / false in
## here), then fades back in. Await the result if the caller needs to know
## when the whole transition (including fade-in) has finished.
## Ignored (no-op) if a transition is already in progress, so rapid
## re-triggers can't desync fade state from camera state.
func switch_camera(on_switch: Callable, duration: float = -1.0) -> void:
	if _busy:
		return
	_busy = true

	var d: float = duration if duration > 0.0 else default_duration

	var fade_out := create_tween()
	fade_out.tween_property(_fade_rect, "modulate:a", 1.0, d * 0.5)
	await fade_out.finished

	on_switch.call()

	var fade_in := create_tween()
	fade_in.tween_property(_fade_rect, "modulate:a", 0.0, d * 0.5)
	await fade_in.finished

	_busy = false
