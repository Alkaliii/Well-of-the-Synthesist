extends Control

@onready var cauldron_ui = $pContManager

var blur

# Called when the node enters the scene tree for the first time.
func _ready():
	#position.x = get_window().size.x
	#position.y = get_window().size.y / 2
	menu_out()
	Global.open_cauldron.connect(open_menu)
	await get_tree().process_frame
	blur = get_tree().get_first_node_in_group("blur")

func open_menu(s : bool):
	match s:
		true: menu_in()
		false: menu_out()

var mtw : Tween
func menu_in():
	if mtw: mtw.kill()
	show()
	cauldron_ui._on_in()
	mtw = create_tween() 
	mtw.tween_property(cauldron_ui,"position:y",(get_viewport_rect().size.y / 2) - (cauldron_ui.size.y / 2),0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	cauldron_ui.global_position.x = (get_viewport_rect().size.x - cauldron_ui.size.x) - 64
	if blur:
		mtw.parallel().tween_property(blur.material,"shader_parameter/blur_amount",5,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await mtw.finished
	#if Global.discovered.is_empty(): cauldron_ui.add_a()

func menu_out():
	if get_tree() == null: return
	if mtw: mtw.kill()
	mtw = create_tween()
	mtw.tween_property(cauldron_ui,"position:y",-(get_viewport_rect().size.y / 2),0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	if blur:
		mtw.parallel().tween_property(blur.material,"shader_parameter/blur_amount",0,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await mtw.finished
	hide()
