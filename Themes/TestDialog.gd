extends PanelContainer

@onready var optionButton = $Control/TabContainer/Buttons/Control/OptionButton
@onready var menuButton = $Control/TabContainer/Buttons/Control/MenuButton
@onready var progressBar = $Control/TabContainer/Extra/ProgressBar
@onready var tree = $Control/TabContainer/Extra/Tree

func _ready():
	pass

func _process(delta):
	progressBar.value += 10 * delta; # 10% per second
	if (progressBar.value >= 100):
		progressBar.value = 0

func _on_close_requested():
	self.queue_free()
