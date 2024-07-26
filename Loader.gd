extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ldr")
	fade(true)

func loadnew(new : String):
	if load(new).can_instantiate():
		await fade(false)
		var c = get_tree().change_scene_to_file(new)
		while true:
			await get_tree().process_frame
			if c in [OK,ERR_CANT_OPEN]: break
		await get_tree().create_timer(0.25).timeout
		fade(true)
	else:
		printerr("transition failed")

func fade(s : bool):
	var tw = create_tween()
	match s:
		true:
			tw.tween_property(self,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
			hide()
		false:
			show()
			tw.tween_property(self,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
