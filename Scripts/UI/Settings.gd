extends Node
# Don't use class names on global scripts

const _SETTINGS_FILE_PATH: String = "user://settings.cfg"

## Settings values
var sensitivity: float
var master_volume: float
var music_volume: float
var sfx_volume: float
var window_mode: int

## Default settings values
const DEFAULT_SENSITIVITY: float = 1.0
const DEFAULT_MASTER_VOLUME: float = 1.0
const DEFAULT_MUSIC_VOLUME: float = 1.0
const DEFAULT_SFX_VOLUME: float = 1.0
const DEFAULT_WINDOW_MODE: int = 2 # Fullscreen (Index 0 = Windowed, 1 = Maximized, 2 = Fullscreen, 3 = Exclusive Fullcreen)

var master_bus_index: int
var music_bus_index: int
var sfx_bus_index: int

## Emitted when settings menu is saved which is when new settings should be applied
signal on_settings_save


## Initialize settings, called before _ready()
func _init() -> void:
	master_bus_index = AudioServer.get_bus_index("Master")
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	load_settings()


## Sets all config file values, then saves the config file to the player's computer
func save_settings() -> void:
	var config = ConfigFile.new()
	
	config.set_value("general", "sensitivity", sensitivity)
	config.set_value("general", "master_volume", master_volume)
	config.set_value("general", "music_volume", music_volume)
	config.set_value("general", "sfx_volume", sfx_volume)
	config.set_value("general", "window_mode", window_mode)
	
	config.save(_SETTINGS_FILE_PATH)
	on_settings_save.emit()
	
	## Apply audio settings
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(sfx_volume))


## Loads the config file and initializes all settings variables
## If no config file exists a new one is created with default values.
func load_settings() -> void:
	var config = ConfigFile.new()
	
	# Load data from a file, if null it will use the default constants
	var err = config.load(_SETTINGS_FILE_PATH)
	sensitivity = config.get_value("general", "sensitivity", DEFAULT_SENSITIVITY)
	master_volume = config.get_value("general", "master_volume", DEFAULT_MASTER_VOLUME)
	music_volume = config.get_value("general", "music_volume", DEFAULT_MUSIC_VOLUME)
	sfx_volume = config.get_value("general", "sfx_volume", DEFAULT_SFX_VOLUME)
	window_mode = config.get_value("general", "window_mode", DEFAULT_WINDOW_MODE)
	
	# Save settings if loading failed
	if err != OK:
		printerr("[Settings] error loading config file at path: ", _SETTINGS_FILE_PATH, "\nCreating new config file with default values")
		save_settings()
