extends Control

@export var debug := true
@export var ex := false
@onready var displays = $Control/ScrollContainer/HBoxContainer/Displays
@onready var scroll_container = $Control/ScrollContainer
@onready var tooltip = $tooltip
@onready var label = $Label
@onready var licon = $Label/HBoxContainer/licon
@onready var ltxt = $Label/HBoxContainer/ltxt

enum arrangements {
	PARTICLE,
	ALLOY,
}
@export var contfor : arrangements = arrangements.PARTICLE

var icelement : Array[String] = []
var icalloy : Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	correct_self(contfor)
	phill()
	Global.add_unit.connect(add_unit_to_cont)
	if ex:
		Global.start_drag.connect(start_autoscroll)
		Global.stop_drag.connect(stop_autoscroll)

var autoscrl := false
var right : Vector2
var left : Vector2
func start_autoscroll():
	var gr := get_global_rect()
	right = gr.end
	left = gr.position
	#print(right," ",left)
	autoscrl = true
func stop_autoscroll():
	autoscrl = false
	#displays.queue_sort()

func _process(delta):
	if autoscrl:
		if abs((get_global_mouse_position().x - left.x)) < 35 and scroll_container.scroll_horizontal != scroll_container.get_h_scroll_bar().min_value:
			scroll_container.scroll_horizontal -= 3
			#print("as left ",scroll_container.scroll_horizontal)
		elif abs((get_global_mouse_position().x - right.x)) < 35 and scroll_container.scroll_horizontal != scroll_container.get_h_scroll_bar().max_value:
			scroll_container.scroll_horizontal += 3
			#print("as right ",scroll_container.scroll_horizontal)

func phill():
	#phoney fill
	if debug and contfor == arrangements.PARTICLE: for i in 30:#randi_range(1,1):
		add_unit_to_cont(Element.get_random(Vector2i(0,0)),false)
		await get_tree().process_frame
	
	if debug and contfor == arrangements.ALLOY: for i in randi_range(3,6):
		await add_unit_to_cont(Alloy.get_random(),false)
	Global.finish_pop.emit()
	sort_cont_unit()

func correct_self(na : arrangements):
	contfor = na
	match na:
		arrangements.PARTICLE:
			tooltip.position = Vector2(-40,0)
			label.position = Vector2(0,233)
			ltxt.text = "particles"
			licon.texture.region = Rect2(96,0,96,96)
		arrangements.ALLOY:
			tooltip.position = Vector2(size.x - 20,0)
			label.position = Vector2(size.x - label.size.x,233)
			ltxt.text = "alloys"
			licon.texture.region = Rect2(0,0,96,96)

func show_tt(w):
	if w == null:
		tooltip.hide()
	else:
		tooltip.set_tooltip(w)
		tooltip.show()

const DISPLAY_PARTICLE = preload("res://Game/UI/display_particle.tscn")
func add_unit_to_cont(what : aUnit,fpop := true):
	if !ex:
		if what is Element:
			if what.get_nameb() in icelement: 
				print("Already in cont ",what.get_nameb())
				return
			icelement.append(what.get_nameb())
		elif what is Alloy:
			if what.get_nameb() in icalloy:
				print("Already in cont ",what.get_nameb())
				return
			icalloy.append(what.get_nameb())
	if !Global.discovered.has(what.get_nameb()):
		Global.discovered.append(what.get_nameb())
	var new = DISPLAY_PARTICLE.instantiate()
	new.follow_mouse_behaviour = new.fb.NEVER
	if ex:
		new.follow_mouse_behaviour = new.fb.NORMAL
		new.return_on_bad_drop = true
		new.perform_merge = true
	new.emit_signal_on_click = true
	new.signal_for_tooltip_on_hover = true
	new.fade_on_right_click = true
	new.show_my_tooltip.connect(show_tt)
	displays.add_child(new)
	new.qhide()
	new.set_particle(what)
	var tw = create_tween()
	tw.tween_property(scroll_container,"scroll_horizontal",scroll_container.get_h_scroll_bar().max_value,0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tw.finished
	await new.fshow()
	if fpop: Global.finish_pop.emit()
	#finish pop

func clear_cont():
	for i in displays.get_children():
		i.get_parent().remove_child(i)
		i.queue_free()

func reset_top():
	for i in displays.get_children():
		if "top_level" in i: i.top_level = false

func sort_cont_unit():
	reset_top()
	var child_list = displays.get_children()
	var num_children = child_list.size()
	for ii in range(0, num_children):
		for i in range(0, num_children):
			if i+1 < num_children:
				var a = displays.get_child(i)
				var b = displays.get_child(i+1)
				var asum = a.what_unit.get_particle_sum() + 50 if a.what_unit is Alloy else 0
				var bsum = b.what_unit.get_particle_sum() + 50 if b.what_unit is Alloy else 0
				if asum > bsum:
					displays.move_child(displays.get_child(i+1),i)
				#match contfor:
					#arrangements.PARTICLE:
						#if a.what_unit.particle > b.what_unit.particle:
							#displays.move_child(displays.get_child(i+1),i)
					#arrangements.ALLOY:
						#if a.what_unit.get_particle_sum() > b.what_unit.get_particle_sum():
							#displays.move_child(displays.get_child(i+1),i)
	displays.queue_sort()
	#VFlowContainer


func _on_sort_pressed():
	Global.smallnote.emit("Container Sorted")
	sort_cont_unit()
