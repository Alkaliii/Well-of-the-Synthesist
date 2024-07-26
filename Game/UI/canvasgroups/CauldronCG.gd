extends CanvasGroup

@onready var cauldron_ui = $CauldronUI

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = (get_window().size / 2).x
	menu_out()
	Global.open_cauldron.connect(open_menu)

func open_menu(s : bool):
	match s:
		true: menu_in()
		false: menu_out()

var mtw : Tween
func menu_in():
	if mtw: mtw.kill()
	show()
	mtw = create_tween()
	mtw.tween_property(cauldron_ui,"position:y",0,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await mtw.finished
	if Global.discovered.is_empty(): cauldron_ui.add_a()

func menu_out():
	if get_tree() == null: return
	if mtw: mtw.kill()
	mtw = create_tween()
	mtw.tween_property(cauldron_ui,"position:y",-(cauldron_ui.size.y / 2),0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	await mtw.finished
	hide()
