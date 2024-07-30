extends Control

@onready var dop = $CanvasLayer/HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	if OS.has_feature("debug"): dop.show()
	else: dop.hide()

func _on_reset_pressed():
	print("RCS")
	Global.discovered.clear()
	Global.tiers_availible.clear()
	Global.previously_performed_reactions.clear()
	Global.reset()
	get_tree().reload_current_scene()
