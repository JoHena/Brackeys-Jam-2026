extends Node

## Settings values
var window_mode: int
var sensitivity: float
var master_volume: float
var music_volume: float
var sfx_volume: float

## Default settings values
const _DEFAULT_SENSITIVITY : float = 1.0
const _DEFAULT_MASTER_VOLUME: float = 1.0
const _DEFAULT_MUSIC_VOLUME : float = 1.0
const _DEFAULT_SFX_VOLUME: float = 1.0

## Scene references
@onready var _sens_value_lbl := $SettingsVBox/SensHBox/SensSliderHBox/SensValueLbl
@onready var _sens_slider := $SettingsVBox/SensHBox/SensSliderHBox/SensHSlider
@onready var _sens_reset_btn := $SettingsVBox/SensHBox/SensSliderHBox/SensResetBtn

@onready var _master_vol_value_lbl := $SettingsVBox/MasterVolHBox/MasterVolSliderHBox/MasterVolValueLbl
@onready var _master_vol_slider := $SettingsVBox/MasterVolHBox/MasterVolSliderHBox/MasterVolHSlider
@onready var _master_vol_reset_btn := $SettingsVBox/MasterVolHBox/MasterVolSliderHBox/MasterVolResetBtn

@onready var _music_vol_value_lbl := $SettingsVBox/MusicVolHBox/MusicVolSliderHBox/MusicVolValueLbl
@onready var _music_vol_slider := $SettingsVBox/MusicVolHBox/MusicVolSliderHBox/MusicVolHSlider
@onready var _music_vol_reset_btn := $SettingsVBox/MusicVolHBox/MusicVolSliderHBox/MusicVolResetBtn

@onready var _sfx_vol_value_lbl := $SettingsVBox/SFXVolHBox/SFXVolSliderHBox/SFXVolValueLbl
@onready var _sfx_vol_slider := $SettingsVBox/SFXVolHBox/SFXVolSliderHBox/SFXVolHSlider
@onready var _sfx_vol_reset_btn := $SettingsVBox/SFXVolHBox/SFXVolSliderHBox/SFXVolResetBtn

@onready var _window_mode_option_btn := $SettingsVBox/WindowModeHBox/WindowModeSliderHBox/WindowModeOptionBtn

var reset_btn_disabled_color: Color = Color(1, 1, 1, 0.5)
var reset_btn_normal_color: Color = Color(1, 1, 1, 0.9)

## TODO - make a ready function which loads saved values. Or at least initialize reset buttons to disabled


## Updates sensitivity and reset button disabled state
func _set_sensitivity(value: float) -> void:
	sensitivity = value
	_sens_value_lbl.text = str(sensitivity)
	
	if sensitivity == _DEFAULT_SENSITIVITY: # Disable reset button
		_sens_reset_btn.disabled = true
		_sens_reset_btn.self_modulate = reset_btn_disabled_color
	elif _sens_reset_btn.disabled == true: # Enable reset button
		_sens_reset_btn.disabled = false
		_sens_reset_btn.self_modulate = reset_btn_normal_color

## Resets sensitivity to the default value and disables reset button
func _on_sens_reset_btn_pressed() -> void:
	sensitivity = _DEFAULT_SENSITIVITY
	_sens_slider.value = sensitivity
	_sens_value_lbl.text = str(sensitivity)
	
	_sens_reset_btn.disabled = true
	_sens_reset_btn.self_modulate = reset_btn_disabled_color


## Updates master volume and reset button disabled state
func _set_master_volume(value: float) -> void:
	master_volume = value
	_master_vol_value_lbl.text = str(int(master_volume * 100)) + "%"
	
	if master_volume == _DEFAULT_MASTER_VOLUME: # Disable reset button
		_master_vol_reset_btn.disabled = true
		_master_vol_reset_btn.self_modulate = reset_btn_disabled_color
	elif _master_vol_reset_btn.disabled == true: # Enable reset button
		_master_vol_reset_btn.disabled = false
		_master_vol_reset_btn.self_modulate = reset_btn_normal_color

## Resets master volume to the default value and disables reset button
func _on_master_vol_reset_btn_pressed() -> void:
	master_volume = _DEFAULT_MASTER_VOLUME
	_master_vol_slider.value = master_volume
	_master_vol_value_lbl.text = str(int(master_volume * 100)) + "%"
	
	_master_vol_reset_btn.disabled = true
	_master_vol_reset_btn.self_modulate = reset_btn_disabled_color


## Updates music volume and reset button disabled state
func _set_music_volume(value: float) -> void:
	music_volume = value
	_music_vol_value_lbl.text = str(int(music_volume * 100)) + "%"
	
	if music_volume == _DEFAULT_MUSIC_VOLUME: # Disable reset button
		_music_vol_reset_btn.disabled = true
		_music_vol_reset_btn.self_modulate = reset_btn_disabled_color
	elif _music_vol_reset_btn.disabled == true: # Enable reset button
		_music_vol_reset_btn.disabled = false
		_music_vol_reset_btn.self_modulate = reset_btn_normal_color

## Resets music volume to the default value and disables reset button
func _on_music_vol_reset_btn_pressed() -> void:
	music_volume = _DEFAULT_MUSIC_VOLUME
	_music_vol_slider.value = music_volume
	_music_vol_value_lbl.text = str(int(music_volume * 100)) + "%"
	
	_music_vol_reset_btn.disabled = true
	_music_vol_reset_btn.self_modulate = reset_btn_disabled_color


## Updates SFX volume and reset button disabled state
func _set_sfx_volume(value: float) -> void:
	sfx_volume = value
	_sfx_vol_value_lbl.text = str(int(sfx_volume * 100)) + "%"
	
	if sfx_volume == _DEFAULT_SFX_VOLUME: # Disable reset button
		_sfx_vol_reset_btn.disabled = true
		_sfx_vol_reset_btn.self_modulate = reset_btn_disabled_color
	elif _sfx_vol_reset_btn.disabled == true: # Enable reset button
		_sfx_vol_reset_btn.disabled = false
		_sfx_vol_reset_btn.self_modulate = reset_btn_normal_color

## Resets SFX volume to the default value and disables reset button
func _on_sfx_vol_reset_btn_pressed() -> void:
	sfx_volume = _DEFAULT_SFX_VOLUME
	_sfx_vol_slider.value = music_volume
	_sfx_vol_value_lbl.text = str(int(sfx_volume * 100)) + "%"
	
	_sfx_vol_reset_btn.disabled = true
	_sfx_vol_reset_btn.self_modulate = reset_btn_disabled_color


## Sets the window mode (id 0 = Windowed, 2 = Maximized, 3 = Fullscreen, 4 = Exclusive Fullscreen)
func _set_window_mode(value: int) -> void:
	if value < 0 or value > 4: 
		printerr("[Settings] window mode value must be between 0-4. Provided value is ", value)
		return
	
	window_mode = value
	_window_mode_option_btn.selected = window_mode # Update for when set from save file
	
	# The enum value correlates with the option's id
	var window_mode_enum := _window_mode_option_btn.get_selected_id() as DisplayServer.WindowMode
	DisplayServer.window_set_mode(window_mode_enum)


## TODO
func _on_save_and_return_button_pressed():
	pass # Replace with function body.
