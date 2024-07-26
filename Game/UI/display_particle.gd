extends PanelContainer

enum fb {
	NEVER,
	NORMAL,
	ALWAYS
}
@export var follow_mouse_behaviour := fb.NORMAL
@export var emit_signal_on_click := false
@export var show_tooltip_on_hover := false
@export var signal_for_tooltip_on_hover := false
@export var fade_on_right_click := false
@export var debug := false

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0

@export_category("Oscillator")
@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0

var displacement: float = 0.0 
var oscillator_velocity: float = 0.0

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2

@onready var spacers = [$Particle/GridCon/spaceA,$Particle/GridCon/spaceB]
@onready var texture: SubViewportContainer = $Particle/GridCon/ParticleA/SubViewportContainer
@onready var textureB: SubViewportContainer = $Particle/GridCon/ParticleB/SubViewportContainer
@onready var ants = $Particle/focused
@onready var glow = $Particle/Glow
@onready var tooltip = $Particle/tooltip

var what_unit : aUnit
#const pTOOLTIP = preload("res://Game/UI/particletooltip.tscn")
signal show_my_tooltip


func _ready() -> void:
	# Convert to radians because lerp_angle is using that
	if debug: 
		what_unit = aUnit.get_random()
		print(what_unit.get_name())
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = size/2
	resized.connect(_on_resized)
	
	if follow_mouse_behaviour == fb.ALWAYS: 
		following_mouse = true
		qhide()
		Global.start_drag.connect(handle_global_drag)
		glow.modulate.a = 1.0
	else:
		Global.finish_pop.connect(glow_in)
		#var nc = Color.WHITE
		#nc.a = 0
		#ants.material.set_shader_parameter("ant_color_1",nc)
	
	if what_unit: set_particle(what_unit)
	
	if debug:
		await get_tree().create_timer(0.3).timeout
		await fhide()
		await get_tree().create_timer(0.3).timeout
		await fshow()

func rand_det():
	await get_tree().process_frame
	texture.material.set_shader_parameter("offset_time",Vector2(randf(),randf()))
	textureB.material.set_shader_parameter("offset_time",Vector2(randf(),randf()))
	glow.material.set_shader_parameter("offset_time",Vector2(randf(),randf()))

func handle_global_drag():
	if !Global.dragging is aUnit: return
	set_particle(Global.dragging)
	fshow()

func glow_in():
	var tw = create_tween()
	tw.tween_property(glow,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)

func set_particle(p : aUnit):
	what_unit = p
	if p is Alloy:
		$Particle/GridCon/ParticleB.show()
		var col : Color = Alloy.get_alloy_color(p.particleA,p.particleB)
		set_p_color(col)
	if p is Element:
		$Particle/GridCon/ParticleB.hide()
		set_p_color(Element.get_particle_color(p.particle))
	set_p_icon()
	rand_det()

func set_p_color(colr : Color):
	glow.material.set_shader_parameter("border_color",colr)
	glow.material.set_shader_parameter("mana_color",colr)
	#print(colr.get_luminance())
	if colr.get_luminance() > 0.75:
		glow.material.set_shader_parameter("glow_strength",-1.0)
	else: glow.material.set_shader_parameter("glow_strength",2.0)

func set_p_icon():
	if !what_unit: return
	if what_unit is Alloy:
		texture.material.set_shader_parameter("atlas_pos",what_unit.particleB)
		textureB.material.set_shader_parameter("atlas_pos",what_unit.particleA)
	if what_unit is Element:
		texture.material.set_shader_parameter("atlas_pos",what_unit.particle)

func _on_resized():
	pivot_offset = size/2

func fshow():
	show()
	var tw = create_tween()
	tw.tween_property(texture.material,"shader_parameter/alpha",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(textureB.material,"shader_parameter/alpha",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(self,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
	if follow_mouse_behaviour == fb.ALWAYS:
		tw.parallel().tween_method(tw_acaona,0.0,1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished

func fhide():
	var tw = create_tween()
	tw.tween_property(texture.material,"shader_parameter/alpha",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(textureB.material,"shader_parameter/alpha",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(self,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
	if follow_mouse_behaviour == fb.ALWAYS:
		tw.parallel().tween_method(tw_acaona,1.0,0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	hide()

func qhide():
	texture.material.set_shader_parameter("alpha",0.0)
	textureB.material.set_shader_parameter("alpha",0.0)
	modulate.a = 0
	hide()

func _process(delta: float) -> void:
	rotate_velocity(delta)
	follow_mouse(delta)

func rotate_velocity(delta: float) -> void:
	if not following_mouse: return
	var center_pos: Vector2 = global_position - (size/2.0)
	#print("Pos: ", center_pos)
	#print("Pos: ", last_pos)
	# Compute the velocity
	velocity = (position - last_pos) / delta
	last_pos = position
	
	#print("Velocity: ", velocity)
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	rotation = displacement

func follow_mouse(delta: float) -> void:
	if not following_mouse: return
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (size/2.0)

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	#if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if emit_signal_on_click:
			Global.dragging = what_unit
			Global.start_drag.emit()
		if follow_mouse_behaviour in [fb.ALWAYS,fb.NEVER]: return
		following_mouse = true
		#create_tween().tween_property(ants,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
		create_tween().tween_method(tw_acaona,0.0,1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	elif event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT and fade_on_right_click:
		toggle_fade()
	else:
		if follow_mouse_behaviour in [fb.ALWAYS,fb.NEVER]: 
			if follow_mouse_behaviour == fb.ALWAYS:
				if visible: 
					Global.stop_drag.emit()
					#print("DROPPED")
				fhide()
			return
		# drop card
		following_mouse = false
		create_tween().tween_method(tw_acaona,1.0,0.0,0.25).set_ease(Tween.EASE_IN_OUT)
		if tween_handle and tween_handle.is_running():
			tween_handle.kill()
		tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_handle.tween_property(self, "rotation", 0.0, 0.3)

var ftoggle := false
func toggle_fade():
	match ftoggle:
		true:
			dopacity(1.0)
		false:
			dopacity(0.2)
	
	ftoggle = !ftoggle

func dopacity(no : float):
	var tw = create_tween()
	tw.tween_property(texture.material,"shader_parameter/alpha",no,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(textureB.material,"shader_parameter/alpha",no,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(self,"modulate:a",no,0.25).set_ease(Tween.EASE_IN_OUT)

func tw_acaona(new_alpha : float):
	#tween ant color alpha on ants shader
	var nc = ants.material.get_shader_parameter("ant_color_1")
	nc.a = new_alpha
	ants.material.set_shader_parameter("ant_color_1",nc)

func _on_gui_input(event: InputEvent) -> void:
	
	handle_mouse_click(event)
	
	# Don't compute rotation when moving the card
	if following_mouse: return
	if not event is InputEventMouseMotion: return
	
	# Handles rotation
	# Get local mouse pos
	var mouse_pos: Vector2 = get_local_mouse_position()
	#print("Mouse: ", mouse_pos)
	#print("Card: ", position + size)
	var diff: Vector2 = (position + size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	#print("Lerp val x: ", lerp_val_x)
	#print("lerp val y: ", lerp_val_y)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	#print("Rot x: ", rot_x)
	#print("Rot y: ", rot_y)
	
	texture.material.set_shader_parameter("x_rot", rot_y)
	texture.material.set_shader_parameter("y_rot", rot_x)
	textureB.material.set_shader_parameter("x_rot", rot_y)
	textureB.material.set_shader_parameter("y_rot", rot_x)

func _on_mouse_entered() -> void:
	if show_tooltip_on_hover:
		tooltip.set_tooltip(what_unit)
		tooltip.global_position = global_position + Vector2(35,35)
		tooltip.show()
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	if what_unit is Element:
		tween_hover.parallel().tween_property(glow,"modulate:a",0.2,0.25)
		#var spacers = [$ParticleA/spaceA,$ParticleA/spaceB,$ParticleA/spaceC]
		for s in spacers: s.hide()
		$Particle/GridCon.columns = 1
	if signal_for_tooltip_on_hover: 
		await get_tree().process_frame
		show_my_tooltip.emit(what_unit)

func _on_mouse_exited() -> void:
	# Reset rotation
	if signal_for_tooltip_on_hover: show_my_tooltip.emit(null)
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	tween_rot.tween_property(textureB.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(textureB.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
	if what_unit is Element:
		tween_hover.parallel().tween_property(glow,"modulate:a",1.0,0.25)
		#var spacers = [$ParticleA/spaceA,$ParticleA/spaceB,$ParticleA/spaceC]
		for s in spacers: s.show()
		$Particle/GridCon.columns = 2
	if show_tooltip_on_hover:
		tooltip.hide()
