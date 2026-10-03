extends Node
class_name PauseMenu


func _ready() -> void:
	self.visible = false


## Toggles pause menu when Pause input map action is pressed 
func _input(event) -> void:
	if event.is_action_pressed("Pause"):
		_toggle_pause_menu()


## Hides/Shows the pause menu
func _toggle_pause_menu() -> void:
	self.visible = not self.visible
	
	get_tree().paused = not get_tree().paused # Stop time
	
	# Toggle mouse visibility
	if self.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Resumes the game by toggling the pause menu
func _on_resume_button_pressed():
	_toggle_pause_menu()


## Opens the settings menu NOTE: currently not implemented so button is disabled
func _on_settings_button_pressed():
	pass # Replace with function body.


## Closes the game
func _on_quit_button_pressed():
	get_tree().quit()
