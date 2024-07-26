extends Node

var afor : String
var bfor : String

@export var slidera : HSlider
@export var sliderb : HSlider
signal set_iso

func _on_isoslider_a_drag_ended(value_changed):
	if value_changed and slidera:
		asnap_valid(slidera.value)

func asnap_valid(value_changed):
	if afor and Global.tiers_availible.has(afor):
		slidera.value = closest(value_changed,Global.tiers_availible[afor])
		set_iso.emit(true)
	else:
		printerr("noafor")

func _on_isoslider_b_drag_ended(value_changed):
	if value_changed and sliderb:
		bsnap_valid(sliderb.value)

func bsnap_valid(value_changed):
	if bfor and Global.tiers_availible.has(bfor):
		sliderb.value = closest(value_changed,Global.tiers_availible[bfor])
		set_iso.emit(true)
	else:
		printerr("nobfor")

func closest(value: int, vset: PackedInt32Array):
	var closest_value
	var closest_difference = INF
	
	for v in vset:
		var difference = abs(value - v)
		if difference < closest_difference:
			closest_difference = difference
			closest_value = v
	
	return closest_value


func _on_isoslider_a_mouse_exited():
	slidera.release_focus()
	asnap_valid(slidera.value)


func _on_isoslider_b_mouse_exited():
	sliderb.release_focus()
	bsnap_valid(sliderb.value)
