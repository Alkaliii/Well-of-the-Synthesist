extends ColorRect

var react_to_drag := false
var dragging = false
signal dropped_here

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.start_drag.connect(fshow)
	Global.stop_drag.connect(fhide)
	fhide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !react_to_drag: return
	if !dragging: return
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
			dhtw.tween_method(tw_accona,material.get_shader_parameter("ant_color_1"),Color.WHITE,0.15).set_ease(Tween.EASE_IN_OUT)
			material.set_shader_parameter("ant_speed",60)
		1:
			dhtw.tween_method(tw_accona,material.get_shader_parameter("ant_color_1"),Color("#e62200"),0.15).set_ease(Tween.EASE_IN_OUT)
			material.set_shader_parameter("ant_speed",30)
	await dhtw.finished
	dhon = z

func fshow():
	if !react_to_drag: return
	dragging = true
	material.set_shader_parameter("ant_color_1",Color("#e62200"))
	dhon = 1
	show()
	var tw = create_tween()
	tw.tween_method(tw_acaona,0.0,1.0,0.25).set_ease(Tween.EASE_IN_OUT)

func check_mouse() -> bool:
	var points = [Vector2(0,0),Vector2(24,24),Vector2(-24,24),Vector2(24,-24),Vector2(-24,-24)]
	for p in points:
		if get_global_rect().has_point(get_global_mouse_position() + p):
			return true
	return false

func fhide():
	dragging = false
	var points = [Vector2(0,0),Vector2(24,24),Vector2(-24,24),Vector2(24,-24),Vector2(-24,-24)]
	for p in points:
		if get_global_rect().has_point(get_global_mouse_position() + p): 
			dropped_here.emit()
			break
	
	if !react_to_drag: return
	var tw = create_tween()
	tw.tween_method(tw_acaona,1.0,0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	hide()

func tw_acaona(new_alpha : float):
	#tween ant color alpha on ants shader
	var nc = material.get_shader_parameter("ant_color_1")
	nc.a = new_alpha
	material.set_shader_parameter("ant_color_1",nc)

func tw_accona(new_color : Color):
	material.set_shader_parameter("ant_color_1",new_color)
