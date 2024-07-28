extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_entered.connect(menter)
	mouse_exited.connect(mexit)

var stw : Tween
func menter():
	if disabled: return
	pivot_offset = size/2
	if stw: stw.kill()
	stw = create_tween()
	stw.tween_property(self,"scale",Vector2(1.3,1.3),0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func mexit():
	pivot_offset = size/2
	if stw: stw.kill()
	stw = create_tween()
	stw.tween_property(self,"scale",Vector2.ONE,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
