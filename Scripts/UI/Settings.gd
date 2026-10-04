extends Node

## Settings values
var window_mode: int
var sensitivity: float
var master_volume: float
var music_volume: float
var sfx_volume: float

## Default settings values
const _DEFAULT_WINDOW_MODE: int = 1 # TODO idk which enum is default
const _DEFAULT_SENSITIVITY : float = 1.0
const _DEFAULT_MASTER_VOLUME: float = 1.0
const _DEFAULT_MUSIC_VOLUME : float = 1.0
const _DEFAULT_SFX_VOLUME: float = 1.0

## Scene references
@onready var _sens_value_lbl := $SettingsVBox/SensHBox/SensSliderHBox/SensValueLbl
@onready var _sens_slider := $SettingsVBox/SensHBox/SensSliderHBox/SensHSlider


func _ready():
	pass # Replace with function body.







## Updates sensitivity and it's value label when slider value changes
func _on_sens_h_slider_value_changed(value):
	sensitivity = value
	_sens_value_lbl.text = str(sensitivity)


## Resets sensitivity and it's value label to the default value when pressed
func _on_sens_reset_btn_pressed():
	_sens_slider.value = _DEFAULT_SENSITIVITY
	sensitivity = _DEFAULT_SENSITIVITY
	_sens_value_lbl.text = str(sensitivity)
