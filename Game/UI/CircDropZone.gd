extends Control

@onready var cdz = $CircDropZone

var react_to_drag := false
var dragging = false
signal dropped_here

var circle_spd := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.start_drag.connect(fshow)
	Global.stop_drag.connect(fhide)
	fhide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !react_to_drag: return
	if !dragging: return
	var tim = cdz.material.get_shader_parameter("fake_time")
	var ntim = (tim + (delta * circle_spd))
	cdz.material.set_shader_parameter("fake_time",ntim)
	var ckm = check_mouse()
	if dhon == 1 and ckm:
		drop_help(0)
	elif dhon == 0 and !ckm:
		drop_help(1)

var dhtw : Tween
var dhon : int = 0
func drop_help(z : int):
	#0 good, 1 bad
	if dhtw: dhtw.kill()
	dhtw = create_tween()
	match z:
		0:
			dhtw.tween_property(self,"modulate",Color.WHITE,0.15).set_ease(Tween.EASE_IN_OUT)
			#cdz.material.set_shader_parameter("time_speed",Vector2(2.0,1.0))
			circle_spd = 3
		1:
			dhtw.tween_property(self,"modulate",Color("#e62200"),0.15).set_ease(Tween.EASE_IN_OUT)
			#cdz.material.set_shader_parameter("time_speed",Vector2(1.0,1.0))
			circle_spd = 1
	await dhtw.finished
	dhon = z

func fshow():
	if !react_to_drag: return
	dragging = true
	modulate.r = Color("#e62200").r
	modulate.g = Color("#e62200").g
	modulate.b = Color("#e62200").b
	dhon = 1
	show()
	var tw = create_tween()
	tw.tween_property(self,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)

func check_mouse() -> bool:
	var points = [Vector2(0,0),Vector2(24,24),Vector2(-24,24),Vector2(24,-24),Vector2(-24,-24)]
	for p in points:
		if get_global_rect().has_point(get_global_mouse_position() + p):
			return true
	return false

func set_progress(np : float):
	var tw = create_tween()
	tw.tween_property(cdz.material,"shader_parameter/fill_ratio",np,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#print(str("change ",np))

func fhide():
	dragging = false
	var points = [Vector2(0,0),Vector2(24,24),Vector2(-24,24),Vector2(24,-24),Vector2(-24,-24)]
	for p in points:
		if get_global_rect().has_point(get_global_mouse_position() + p): 
			dropped_here.emit()
			break
	
	if !react_to_drag: return
	circle_spd = 1.0
	var tw = create_tween()
	var white = Color.WHITE
	white.a = 0.5
	tw.tween_property(self,"modulate",white,0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	#hide()
