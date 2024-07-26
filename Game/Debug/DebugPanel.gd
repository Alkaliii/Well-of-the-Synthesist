extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_reset_pressed():
	print("RCS")
	Global.discovered.clear()
	Global.tiers_availible.clear()
	Global.previously_performed_reactions.clear()
	get_tree().reload_current_scene()
