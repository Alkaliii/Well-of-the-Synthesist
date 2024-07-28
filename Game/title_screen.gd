extends Control

@onready var lup = $logo/Up
@onready var lmid = $logo/Mid
@onready var lbot = $logo/Bot

# Called when the node enters the scene tree for the first time.
func _ready():
	bounce_logo()
	intro()
	gui_input.connect(_on_gui_input)
	#Camera position.y 6.2 -> 2.2

func bounce_logo():
	var btw : Tween = create_tween().bind_node(self).set_loops()
	btw.tween_property(lup,"position:y",lup.position.y + 2,1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	btw.parallel().tween_property(lbot,"position:y",lbot.position.y - 2,1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	btw.tween_property(lup,"position:y",lup.position.y - 2,1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.3)
	btw.parallel().tween_property(lbot,"position:y",lbot.position.y + 2,1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@onready var bt = $bt
@onready var tvb = $bt/t
@onready var tip = $bt/t/tip
@onready var ltxt = $bt/t/ltxt
@onready var titlecam = $D3SVC/SV/env/titlecam
var itw : Tween
func intro():
	tip.text = str("Adding to oneself shall raise you higher.")
	ltxt.text = "a + a = b"
	itw = create_tween()
	play_delayed_hush(0,2.8)
	itw.tween_property(bt,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	tip.text = str("Strangers join together to inspire.")
	ltxt.text = "a + b = ab"
	itw = create_tween()
	SFXm.play("res://Assets/Sounds/hushA.wav","master",randf_range(0.9,1.1))
	itw.tween_property(tvb,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.25)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	tip.text = str("This is the mystery of the world disciphered.")
	ltxt.text = "a + bc = abc"
	itw = create_tween()
	SFXm.play("res://Assets/Sounds/hushB.wav","master",randf_range(0.9,1.1))
	itw.tween_property(tvb,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.25)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	itw = create_tween()
	itw.parallel().tween_property(bt,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(2.0)
	show_title()
	await itw.finished
	bt.hide()

func play_delayed_hush(which : int, delay : float):
	await get_tree().create_timer(delay).timeout
	match which:
		0: SFXm.play("res://Assets/Sounds/hushA.wav","master",randf_range(0.9,1.1))
		1: SFXm.play("res://Assets/Sounds/hushB.wav","master",randf_range(0.9,1.1))

@onready var logo = $logo
@onready var ph = $ph
@onready var play = $ph/Play
@onready var settings = $ph/Settings
@onready var returnn = $ph/Return
@onready var help = $ph/Help

@onready var shadow_box = $D3SVC/SV/env/ShadowBox
func show_title():
	on_play = false
	var tw = create_tween()
	play.show()
	logo.show()
	returnn.hide()
	settings.show()
	help.show()
	SFXm.play("res://Assets/Sounds/titlebuildup.wav","master")
	tw.tween_property(titlecam,"position:y",2.2,3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO).set_delay(0.6)
	tw.parallel().tween_property(cauldron,"position:z",0,0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(custom_sage,"position",Vector3(0,1.02,-1.16),0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(shadow_box,"position:z",0,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(logo,"modulate:a",1,0.5).set_ease(Tween.EASE_IN_OUT).set_delay(0.1)
	tw.parallel().tween_property(ph,"modulate:a",1,0.5).set_ease(Tween.EASE_IN_OUT)

func _on_gui_input(event: InputEvent) -> void:
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

	var rot_x: float = rad_to_deg(lerp_angle(0.1, -0.1, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(0.1, -0.1, lerp_val_y))
	#print("Rot x: ", rot_x)
	#print("Rot y: ", rot_y)
	
	titlecam.rotation_degrees.x = -15 + rot_y
	titlecam.rotation_degrees.y = rot_x

func _on_mouse_exited():
	returntcam()

var rtw : Tween
func returntcam():
	if rtw: rtw.kill()
	rtw = create_tween()
	rtw.tween_property(titlecam,"rotation_degrees:x",-15,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	rtw.parallel().tween_property(titlecam,"rotation_degrees:y",0,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func _on_mouse_entered():
	if rtw: rtw.kill()

var on_play = false
func _on_play_pressed():
	play.release_focus()
	#get_tree().get_first_node_in_group("ldr").loadnew("res://Game/game.tscn")
	if on_play:
		Global.player_shader = custom_sage.material_override
		get_tree().get_first_node_in_group("ldr").loadnew("res://Game/game.tscn",true)
	else: open_cc()
	#get_tree().change_scene_to_file("res://Game/game.tscn")

@onready var cc = $CC
@onready var cauldron = $D3SVC/SV/env/Cauldron
@onready var custom_sage = $D3SVC/SV/env/CustomSage
func open_cc():
	on_play = true
	cc.show()
	help.hide()
	settings.hide()
	returnn.show()
	var tw = create_tween()
	tw.tween_property(cc,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(cauldron,"position:z",6,0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(shadow_box,"position:z",6,0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(logo,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT).set_delay(0.1)
	#tw.parallel().tween_property(ph,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(custom_sage,"position",Vector3(0,1.65,0),0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	logo.hide()
	#ph.hide()

func _on_return_pressed():
	returnn.release_focus()
	show_title()
	var tw = create_tween()
	tw.tween_property(cc,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
