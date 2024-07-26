extends CenterContainer
class_name msgbx

@onready var rtl = $msgbox/rtl

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var mtw : Tween
func play_msg(msg : String = "...",length : float = 2.0):
	if mtw : mtw.kill()
	mtw = create_tween()
	rtl.text = msg
	rtl.visible_ratio = 0
	show()
	mtw.tween_property(self,"modulate:a",1.0,0.2).set_ease(Tween.EASE_IN_OUT)
	mtw.parallel().tween_property(rtl,"visible_ratio",1.0,0.4).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(length).timeout
	clear()

func clear():
	if mtw : mtw.kill()
	mtw = create_tween()
	mtw.tween_property(self,"modulate:a",0.0,0.2).set_ease(Tween.EASE_IN_OUT)
