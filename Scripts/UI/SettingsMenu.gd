extends Node
class_name SettingsMenu

## Scene references
@onready var _sens_bkg_txtr := $SettingsVBox/SensBkgTxtr
@onready var _sens_value_lbl := $SettingsVBox/SensBkgTxtr/SensHBox/SensSliderHBox/SensValueLbl
@onready var _sens_slider := $SettingsVBox/SensBkgTxtr/SensHBox/SensSliderHBox/SensHSlider
@onready var _sens_reset_btn := $SettingsVBox/SensBkgTxtr/SensHBox/SensSliderHBox/SensResetBtn

@onready var _master_vol_bkg_txtr := $SettingsVBox/MasterVolBkgTxtr
@onready var _master_vol_value_lbl := $SettingsVBox/MasterVolBkgTxtr/MasterVolHBox/MasterVolSliderHBox/MasterVolValueLbl
@onready var _master_vol_slider := $SettingsVBox/MasterVolBkgTxtr/MasterVolHBox/MasterVolSliderHBox/MasterVolHSlider
@onready var _master_vol_reset_btn := $SettingsVBox/MasterVolBkgTxtr/MasterVolHBox/MasterVolSliderHBox/MasterVolResetBtn

@onready var _music_vol_bkg_txtr := $SettingsVBox/MusicVolBkgTxtr
@onready var _music_vol_value_lbl := $SettingsVBox/MusicVolBkgTxtr/MusicVolHBox/MusicVolSliderHBox/MusicVolValueLbl
@onready var _music_vol_slider := $SettingsVBox/MusicVolBkgTxtr/MusicVolHBox/MusicVolSliderHBox/MusicVolHSlider
@onready var _music_vol_reset_btn := $SettingsVBox/MusicVolBkgTxtr/MusicVolHBox/MusicVolSliderHBox/MusicVolResetBtn

@onready var _sfx_vol_bkg_txtr := $SettingsVBox/SFXVolBkgTexture
@onready var _sfx_vol_value_lbl := $SettingsVBox/SFXVolBkgTexture/SFXVolHBox/SFXVolSliderHBox/SFXVolValueLbl
@onready var _sfx_vol_slider := $SettingsVBox/SFXVolBkgTexture/SFXVolHBox/SFXVolSliderHBox/SFXVolHSlider
@onready var _sfx_vol_reset_btn := $SettingsVBox/SFXVolBkgTexture/SFXVolHBox/SFXVolSliderHBox/SFXVolResetBtn

@onready var _window_mode_bkg_txtr := $SettingsVBox/WindowModeBkgTexture
@onready var _window_mode_option_btn := $SettingsVBox/WindowModeBkgTexture/WindowModeHBox/WindowModeSliderHBox/WindowModeOptionBtn

@onready var _save_and_return_bkg_txtr := $SettingsVBox/SaveAndReturnBkgTexture

var reset_btn_disabled_alpha: float = 0.5
var reset_btn_normal_alpha: float = 0.9

signal on_settings_save_and_close



## When game starts load all settings, and if no config file exists a new one is created
func _ready() -> void:
	self.visible = false
	_set_all_settings() # Initialize settings from config file


## Calls all settings setter functions with values from Settings script
func _set_all_settings() -> void:
	_set_sensitivity(Settings.sensitivity)
	_set_master_volume(Settings.master_volume)
	_set_music_volume(Settings.music_volume)
	_set_sfx_volume(Settings.sfx_volume)
	_set_window_mode(Settings.window_mode)


## Toggles the visibility state of the settings menu
func toggle_visibility() -> void:
	self.visible = not self.visible


func _process(delta) -> void:
	if not self.visible: return
	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	_handle_background_texture_visibility(_sens_bkg_txtr, mouse_pos)
	_handle_background_texture_visibility(_master_vol_bkg_txtr, mouse_pos)
	_handle_background_texture_visibility(_music_vol_bkg_txtr, mouse_pos)
	_handle_background_texture_visibility(_sfx_vol_bkg_txtr, mouse_pos)
	_handle_background_texture_visibility(_window_mode_bkg_txtr, mouse_pos)
	_handle_background_texture_visibility(_save_and_return_bkg_txtr, mouse_pos)


## If mouse is hovering over node, make the background visible, otherwise hide the background
func _handle_background_texture_visibility(node: Control, mouse_pos: Vector2):
	if node.get_global_rect().has_point(mouse_pos):
		node.self_modulate.a = 1 # Make visible
	elif node.self_modulate.a == 1:
		node.self_modulate.a = 0 # Hide if already visible


## Updates sensitivity and reset button disabled state
func _set_sensitivity(value: float) -> void:
	Settings.sensitivity = value
	_sens_slider.value = value
	_sens_value_lbl.text = str(value)
	
	if value == Settings.DEFAULT_SENSITIVITY: # Disable reset button
		_sens_reset_btn.disabled = true
		_sens_reset_btn.self_modulate.a = reset_btn_disabled_alpha
	elif _sens_reset_btn.disabled == true: # Enable reset button
		_sens_reset_btn.disabled = false
		_sens_reset_btn.self_modulate.a = reset_btn_normal_alpha

## Resets sensitivity to the default value and disables reset button
func _on_sens_reset_btn_pressed() -> void:
	Settings.sensitivity = Settings.DEFAULT_SENSITIVITY
	_sens_slider.value = Settings.DEFAULT_SENSITIVITY
	_sens_value_lbl.text = str(Settings.DEFAULT_SENSITIVITY)
	
	_sens_reset_btn.disabled = true
	_sens_reset_btn.self_modulate.a = reset_btn_disabled_alpha


## Updates master volume and reset button disabled state
func _set_master_volume(value: float) -> void:
	Settings.master_volume = value
	_master_vol_slider.value = value
	_master_vol_value_lbl.text = str(int(value * 100)) + "%"
	
	if value == Settings.DEFAULT_MASTER_VOLUME: # Disable reset button
		_master_vol_reset_btn.disabled = true
		_master_vol_reset_btn.self_modulate.a = reset_btn_disabled_alpha
	elif _master_vol_reset_btn.disabled == true: # Enable reset button
		_master_vol_reset_btn.disabled = false
		_master_vol_reset_btn.self_modulate.a = reset_btn_normal_alpha

## Resets master volume to the default value and disables reset button
func _on_master_vol_reset_btn_pressed() -> void:
	Settings.master_volume = Settings.DEFAULT_MASTER_VOLUME
	_master_vol_slider.value = Settings.DEFAULT_MASTER_VOLUME
	_master_vol_value_lbl.text = str(int(Settings.DEFAULT_MASTER_VOLUME * 100)) + "%"
	
	_master_vol_reset_btn.disabled = true
	_master_vol_reset_btn.self_modulate.a = reset_btn_disabled_alpha


## Updates music volume and reset button disabled state
func _set_music_volume(value: float) -> void:
	Settings.music_volume = value
	_music_vol_slider.value = value
	_music_vol_value_lbl.text = str(int(value * 100)) + "%"
	
	if value == Settings.DEFAULT_MUSIC_VOLUME: # Disable reset button
		_music_vol_reset_btn.disabled = true
		_music_vol_reset_btn.self_modulate.a = reset_btn_disabled_alpha
	elif _music_vol_reset_btn.disabled == true: # Enable reset button
		_music_vol_reset_btn.disabled = false
		_music_vol_reset_btn.self_modulate.a = reset_btn_normal_alpha

## Resets music volume to the default value and disables reset button
func _on_music_vol_reset_btn_pressed() -> void:
	Settings.music_volume = Settings.DEFAULT_MUSIC_VOLUME
	_music_vol_slider.value = Settings.DEFAULT_MUSIC_VOLUME
	_music_vol_value_lbl.text = str(int(Settings.DEFAULT_MUSIC_VOLUME * 100)) + "%"
	
	_music_vol_reset_btn.disabled = true
	_music_vol_reset_btn.self_modulate.a = reset_btn_disabled_alpha


## Updates SFX volume and reset button disabled state
func _set_sfx_volume(value: float) -> void:
	Settings.sfx_volume = value
	_sfx_vol_slider.value = value
	_sfx_vol_value_lbl.text = str(int(value * 100)) + "%"
	
	if value == Settings.DEFAULT_SFX_VOLUME: # Disable reset button
		_sfx_vol_reset_btn.disabled = true
		_sfx_vol_reset_btn.self_modulate.a = reset_btn_disabled_alpha
	elif _sfx_vol_reset_btn.disabled == true: # Enable reset button
		_sfx_vol_reset_btn.disabled = false
		_sfx_vol_reset_btn.self_modulate.a = reset_btn_normal_alpha

## Resets SFX volume to the default value and disables reset button
func _on_sfx_vol_reset_btn_pressed() -> void:
	Settings.sfx_volume = Settings.DEFAULT_SFX_VOLUME
	_sfx_vol_slider.value = Settings.DEFAULT_SFX_VOLUME
	_sfx_vol_value_lbl.text = str(int(Settings.DEFAULT_SFX_VOLUME * 100)) + "%"
	
	_sfx_vol_reset_btn.disabled = true
	_sfx_vol_reset_btn.self_modulate.a = reset_btn_disabled_alpha


## Sets the window mode (id 0 = Windowed, 2 = Maximized, 3 = Fullscreen, 4 = Exclusive Fullscreen)
func _set_window_mode(value: int) -> void:
	if value < 0 or value > 4: 
		printerr("[Settings] window mode value must be between 0-4. Provided value is ", value)
		return
	
	Settings.window_mode = value
	_window_mode_option_btn.selected = value
	
	# The enum value correlates with the option's id
	var window_mode_enum := _window_mode_option_btn.get_selected_id() as DisplayServer.WindowMode
	DisplayServer.window_set_mode(window_mode_enum)


## Saves settings and hides the menu
func _on_save_and_return_button_pressed() -> void:
	Settings.save_settings()
	toggle_visibility()
	on_settings_save_and_close.emit()
