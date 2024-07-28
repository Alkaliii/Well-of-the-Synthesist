extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	Global.dropped.connect(check_drop)

func dis(s : bool):
	disabled = s
	$dropoutline.visible = !s

func check_drop():
	var points = [Vector2(0,0),Vector2(24,24),Vector2(-24,24),Vector2(24,-24),Vector2(-24,-24)]
	for p in points:
		if get_global_rect().has_point(get_global_mouse_position() + p):
			if disabled: 
				var n = str("[color=e62200]decay failed[/color], move the cauldron out of shadow.")
				Global.smallnote.emit(n)
				return
			if Global.dragging and "bad_drop" in Global.dragging:
				Global.dragging.bad_drop = false
				var m = Global.dragging
				Global.dragging = null
				Global.stop_drag.emit()
				var calc = AlchemyB.new()
				if calc.can_dk(m.what_unit):
					m._on_mouse_exited()
					var tw = create_tween()
					tw.tween_property(m,"scale",Vector2.ZERO,0.15).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_delay(0.15)
					#tw.parallel().tween_property(m,"rotation_degrees",[-360,360].pick_random(),0.15).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
					await tw.finished
					m.hide()
					m.scale = Vector2.ONE
					Global.return_to_pool.emit(m)
					rotation_degrees = [-360,360].pick_random()
					var new = calc.decay_rx(m.what_unit)
					#if new[0] is Element or new[0] is Alloy:
						#m.set_particle(new[0])
						#tw = create_tween()
						#tw.tween_property(m,"scale",Vector2.ONE,0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.25)
						#tw.parallel().tween_property(m,"rotation_degrees",0,0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
					#if new.size() > 1:
					for i in new:
							#if i == new[0]: continue
						Global.add_unit.emit(i)
					#else: m.global_position = m.original_position
				break
