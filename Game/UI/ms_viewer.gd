extends Control

@onready var synergy_core = $D3SVC/SV/env/SynergyCore
@onready var grid_core = $D3SVC/SV/env/GridCore

@onready var xslider = $Controls/rX/Rotate/xslider
@onready var yslider = $Controls/rY/Rotate/yslider
@onready var zslider = $Controls/rZ/Rotate/zslider

@onready var isonum = $Controls/tier/VBoxContainer/isonum
@onready var isoslider = $Controls/tier/VBoxContainer/isocombo/isoslider
@onready var gen = $Controls/tier/VBoxContainer/gen

const MSL = preload("res://Game/UI/msl.tscn")
var following_mouse := false
var rot_x = 0
var rot_y = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_ms()
	gui_input.connect(_on_gui_input)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if following_mouse:
		calc_rot(delta)
		synergy_core.rotate_x(rot_x)
		synergy_core.rotate_y(rot_y)
		set_sliders()
	grid_core.rotation = synergy_core.rotation

func set_sliders():
	xslider.value = int(synergy_core.rotation_degrees.x) % 360
	yslider.value = int(synergy_core.rotation_degrees.y) % 360
	zslider.value = int(synergy_core.rotation_degrees.z) % 360

var ison : int = 0
func generate_ms():
	var ms = await Global.get_ms(51,51,51,ison)
	for l in synergy_core.get_children():
		synergy_core.remove_child(l)
		l.queue_free()
	
	for l in ms:
		var new = MSL.instantiate()
		synergy_core.add_child(new)
		var tex = ImageTexture.new()
		tex.set_image(l)
		new.material_override.set_shader_parameter("textur",tex)
		new.position.y = remap(ms.find(l)/50.0,0.0,1.0,-0.5,0.5)

func _on_gui_input(event: InputEvent) -> void:
	handle_mouse_click(event)
	if not event is InputEventMouseMotion: return

var prev_mp : Vector2 = Vector2.ZERO
var next_mp : Vector2 = Vector2.ZERO
func calc_rot(delta):
	next_mp = get_global_mouse_position()
	rot_y = (next_mp.x - prev_mp.x) * .1 * delta
	rot_x = (next_mp.y - prev_mp.y) * .1 * delta
	prev_mp = next_mp

#func calc_rot():
	## Handles rotation
	## Get local mouse pos
	#var mouse_pos: Vector2 = get_local_mouse_position()
	##print("Mouse: ", mouse_pos)
	##print("Card: ", position + size)
	#var diff: Vector2 = (position + size) - mouse_pos
#
	#var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	#var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	##print("Lerp val x: ", lerp_val_x)
	##print("lerp val y: ", lerp_val_y)
#
	#rot_y += rad_to_deg(lerp_angle(-1, 1, lerp_val_x))
	#rot_x += rad_to_deg(lerp_angle(1, -1, lerp_val_y))

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	#if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		following_mouse = true
		prev_mp = get_global_mouse_position()
		#print("hi")
	else:
		following_mouse = false

func _on_zslider_value_changed(value):
	if following_mouse : return
	synergy_core.rotation_degrees.z = value

func _on_yslider_value_changed(value):
	if following_mouse : return
	synergy_core.rotation_degrees.y = value

func _on_xslider_value_changed(value):
	if following_mouse : return
	synergy_core.rotation_degrees.x = value

func _on_xslider_drag_ended(value_changed):
	xslider.release_focus()

func _on_yslider_drag_ended(value_changed):
	yslider.release_focus()

func _on_zslider_drag_ended(value_changed):
	zslider.release_focus()

func _on_isoslider_value_changed(value):
	isonum.text = str(value)
	ison = value

func _on_isoslider_drag_ended(value_changed):
	isoslider.release_focus()

func _on_gen_pressed():
	gen.release_focus()
	gen.disabled = true
	await generate_ms()
	gen.disabled = false
