extends Panel

const speed = 45.0
@export var debug := false

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.smallnote.connect(spawn_noti)
	if debug: test_A()

const test_s = ["yoooooooooooooo","accroding to all known laws of aviation","sup","heyaaaaa","uh","noooooooooooooooooooooooooooooooooooooooooo"]
func test_A():
	spawn_noti(test_s.pick_random())
	await get_tree().create_timer(randf_range(0.2,1.0)).timeout
	test_A()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count() > 0 and !visible: fade(true)
	elif get_child_count() == 0 and visible: fade(false)

const SNT = preload("res://Game/UI/smallnotitext.tscn")
func spawn_noti(text : String):
	var new = SNT.instantiate()
	new.text = text
	var mr = get_child(get_child_count() - 1)
	add_child(new)
	new.position.y = (size.y - new.size.y) / 2.0
	if mr and mr.position.x < 0:
		new.position.x = (mr.position.x - new.size.x) - 15
	else: 
		new.position.x = (0 - new.size.x)
	var t = abs(float(new.position.x - get_window().size.x)) / speed
	var tw = create_tween()
	tw.tween_property(new,"position:x",get_window().size.x,t).set_ease(Tween.EASE_IN_OUT)
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
