extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.smallnote.connect(spawn_noti)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count() > 0 and !visible: fade(true)
	elif get_child_count() == 0 and visible: fade(false)

const SNT = preload("res://Game/UI/smallnotitext.tscn")
func spawn_noti(text : String):
	var new = SNT.instantiate()
	new.text = text
	add_child(new)
	new.position.y = (size.y - new.size.y) / 2.0
	new.position.x = 0 - new.size.x
	var tw = create_tween()
	tw.tween_property(new,"position:x",get_window().size.x,12).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	remove_child(new)
	new.queue_free()

var ftw : Tween
func fade(s:bool):
	if ftw: ftw.kill()
	match s:
		true:
			show()
			ftw = create_tween()
			ftw.tween_property(self,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
			await ftw.finished
		false:
			ftw = create_tween()
			ftw.tween_property(self,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
			await ftw.finished
			hide()
