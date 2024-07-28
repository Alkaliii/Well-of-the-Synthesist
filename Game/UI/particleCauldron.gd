extends Control

@export var debug := true
@export var ex := false
@onready var displays = $Control/ScrollContainer/HBoxContainer/Displays
@onready var scroll_container = $Control/ScrollContainer
@onready var scrollprogress = $scrollprogress
@onready var tooltip = $tt/tooltip
@onready var label = $Label
@onready var licon = $Label/HBoxContainer/licon
@onready var ltxt = $Label/HBoxContainer/ltxt

@onready var sort = $Control/ScrollContainer/HBoxContainer/VBoxContainer/sort
@onready var conjure = $Control/ScrollContainer/HBoxContainer/VBoxContainer/conjure
@onready var decay = $Control/ScrollContainer/HBoxContainer/VBoxContainer/decay

#enum arrangements {
	#PARTICLE,
	#ALLOY,
#}
#@export var contfor : arrangements = arrangements.PARTICLE

var icelement : Array[String] = []
var icalloy : Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#correct_self(contfor)
	phill()
	Global.add_unit.connect(add_unit_to_cont)
	Global.return_to_pool.connect(recycle_instance)
	set_autoscroll()
	#if ex:
		#Global.start_drag.connect(start_autoscroll)
		#Global.stop_drag.connect(stop_autoscroll)

func _on_in():
	#conjure also
	decay.dis(Global.in_shadow)
	conjure.disabled = !Global.can_conjure

var right : Vector2
var left : Vector2
func set_autoscroll():
	var gr := get_global_rect()
	right = gr.end
	left = gr.position
	#print(right," ",left)

func set_scroll():
	var nv = lerp(scrollprogress.material.get_shader_parameter("turn"),float(scroll_container.get_h_scroll_bar().value) / float(scroll_container.get_h_scroll_bar().max_value),0.3)
	scrollprogress.material.set_shader_parameter("turn",nv)

func _process(delta):
	set_scroll()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if abs((get_global_mouse_position().x - left.x)) < 35 and scroll_container.scroll_horizontal != scroll_container.get_h_scroll_bar().min_value:
			scroll_container.scroll_horizontal -= 3
			#print("as left ",scroll_container.scroll_horizontal)
		elif abs((get_global_mouse_position().x - right.x)) < 35 and scroll_container.scroll_horizontal != scroll_container.get_h_scroll_bar().max_value:
			scroll_container.scroll_horizontal += 3
			#print("as right ",scroll_container.scroll_horizontal)

func phill():
	#phoney fill
	if debug: for i in 3:#randi_range(1,1):
		add_unit_to_cont(Element.get_random(Vector2i(0,0)),false)
		await get_tree().process_frame
	
	#if debug and contfor == arrangements.ALLOY: for i in randi_range(3,6):
		#await add_unit_to_cont(Alloy.get_random(),false)
	Global.finish_pop.emit()
	sort_cont_unit()

#func correct_self(na : arrangements):
	#contfor = na
	#match na:
		#arrangements.PARTICLE:
			#tooltip.position = Vector2(-40,0)
			#label.position = Vector2(0,233)
			#ltxt.text = "particles"
			#licon.texture.region = Rect2(96,0,96,96)
		#arrangements.ALLOY:
			#tooltip.position = Vector2(size.x - 20,0)
			#label.position = Vector2(size.x - label.size.x,233)
			#ltxt.text = "alloys"
			#licon.texture.region = Rect2(0,0,96,96)

func show_tt(w):
	if w == null:
		tooltip.hide()
	else:
		tooltip.set_tooltip(w)
		tooltip.show()

@onready var mtooltip = $tt/mtooltip
func show_mtt(w):
	if w == null:
		mtooltip.hide()
	else:
		mtooltip.set_tooltip(w)
		mtooltip.show()

const DISPLAY_PARTICLE = preload("res://Game/UI/display_particle.tscn")
@onready var pool = $Pool
func obtain_instance() -> PanelContainer:
	var c = pool.get_children()
	if c.is_empty(): return DISPLAY_PARTICLE.instantiate()
	else:
		var p = c.pop_back()
		pool.remove_child(p)
		return p

func recycle_instance(s : PanelContainer):
	s._on_mouse_exited()
	s.get_parent().remove_child(s)
	s.disabled = true
	s.top_level = false
	s.position = Vector2.ZERO - s.size
	pool.add_child(s)
	print(pool.get_child_count())
	update_count()

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
	var new = obtain_instance()#DISPLAY_PARTICLE.instantiate()
	new.follow_mouse_behaviour = new.fb.NORMAL
	if ex:
		new.return_on_bad_drop = true
		new.perform_merge = true
		new.disabled = false
	new.emit_signal_on_click = true
	new.signal_for_tooltip_on_hover = true
	new.fade_on_right_click = true
	if !new.show_my_tooltip.is_connected(show_tt):
		new.show_my_tooltip.connect(show_tt)
	if !new.show_my_merge_tooltip.is_connected(show_mtt):
		new.show_my_merge_tooltip.connect(show_mtt)
	displays.add_child(new)
	new.qhide()
	new.set_particle(what)
	#var tw = create_tween()
	#tw.tween_property(scroll_container,"scroll_horizontal",scroll_container.get_h_scroll_bar().max_value,0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#await tw.finished
	await new.fshow()
	if fpop: Global.finish_pop.emit()
	update_count()
	#finish pop

func update_count():
	var c = displays.get_child_count()
	if c < 60:
		ltxt.text = str(c,"/60")
	else:
		ltxt.text = str("[color=e62200][pulse]",c,"[/pulse][/color]/60")

func clear_cont():
	for i in displays.get_children():
		i.get_parent().remove_child(i)
		i.queue_free()

func reset_top():
	for i in displays.get_children():
		if !i.visible: continue
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
				var asum = a.what_unit.get_particle_sum() + (50 if a.what_unit is Alloy else 0)
				var bsum = b.what_unit.get_particle_sum() + (50 if b.what_unit is Alloy else 0)
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
	sort.release_focus()
	Global.smallnote.emit("Container Sorted")
	sort_cont_unit()

@onready var cnjr = $cnjr
@onready var burst = $cnjr/burst
var cnjr_count := 0
func conjure_anim():
	var tw = create_tween()
	cnjr.pivot_offset = cnjr.size/2.0
	pivot_offset = size/2.0
	cnjr.material.set_shader_parameter("t",3.14)
	tw.tween_property(scroll_container,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(cnjr,"color:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(cnjr,"color:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(cnjr.material,"shader_parameter/t",6.28,2.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(cnjr,"color:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT).set_delay(2.0)
	tw.parallel().tween_property(cnjr,"scale",Vector2.ZERO,0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO).set_delay(2.0)
	tw.parallel().tween_property(self,"scale",Vector2(0.9,0.9),0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(2.0)
	tw.tween_property(self,"scale",Vector2.ONE,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(0.25).timeout
	burst.emitting = true
	await tw.finished
	cnjr.scale = Vector2.ONE

func _on_conjure_pressed():
	conjure.release_focus()
	if displays.get_child_count() > 60:
		Global.smallnote.emit("cauldron will boil over if you conjure anymore particles.")
		return
	cnjr_count += 1
	if cnjr_count == 3:
		cnjr_count = 0
		Global.respawn_conjure.emit()
		if [true,false].pick_random() and Global.fusion_count < Global.fusion_lim: Global.wake_sent.emit()
		if range(12).pick_random() == 3: Global.tickle_shadows.emit()
	SFXm.play("res://Assets/Sounds/conjure.wav","master",randf_range(0.95,1.05))
	SFXm.play("res://Assets/Sounds/403970__instantchow__cup-and-straw-bubbles.wav","master",randf_range(0.9,1.1)) 
	await conjure_anim()
	#scroll_container.hide()
	for i in 5:
		match Global.conjure_level:
			0: add_unit_to_cont(Element.get_random(Vector2i(0,3)))
			_: 
				var m = clamp((Global.conjure_level - 1) * 2,0,49)
				add_unit_to_cont(Element.get_random(Vector2i(0 + m,9 + m)))
		await get_tree().process_frame
	conjure.disabled = !Global.can_conjure
	scroll_container.show()
	var tw = create_tween()
	tw.tween_property(scroll_container,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
