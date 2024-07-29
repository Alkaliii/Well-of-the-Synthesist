extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	resized.connect(center_cg)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@onready var cauldron_cg = $CauldronCG
func center_cg():
	cauldron_cg.position.x = size.x / 2

@onready var settings_btn = $Margin/Settings
@onready var settings_panel = $Settings
func _on_settings_pressed():
	settings_btn.release_focus()
	match settings_panel.visible:
		false: settings_panel.open()
		true: settings_panel.close()
