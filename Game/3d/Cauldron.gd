extends AnimatableBody3D

@export var anim_speed := 5.0
@onready var ray = $RayCast3D
@onready var cmesh = $Mesh
@onready var undeglow = $Mesh/Undeglow

var tile_size = 1.6
var in_shadow : int = 0
var conjures : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.sage_bounce.connect(push)
	Global.move_shadows.connect(close_ui)
	Global.force_close_cauldron.connect(close_ui)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var ugtw : Tween
func _process(delta):
	if !Global.in_shadow and in_shadow != 0:
		if ugtw: ugtw.kill()
		ugtw = create_tween()
		if sfx: SFXm.play("res://Assets/Sounds/shadowflameon.wav","sfx",randf_range(0.9,1.1))
		ugtw.tween_property(undeglow.material_override,"shader_parameter/alpha",1.0,0.25).set_ease(Tween.EASE_IN_OUT).set_delay(0.4)
		Global.in_shadow = true
	if Global.in_shadow and in_shadow == 0:
		if ugtw: ugtw.kill()
		ugtw = create_tween()
		if sfx: SFXm.play("res://Assets/Sounds/274309__sophronsinesounddesign__match-extinguish-2.wav","sfx",randf_range(0.9,1.1))
		ugtw.tween_property(undeglow.material_override,"shader_parameter/alpha",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
		Global.in_shadow = false
	if Global.can_conjure and conjures == 0:
		Global.can_conjure = false
	if !Global.can_conjure and conjures != 0:
		Global.can_conjure = true

var moving := false
func push():
	#need way to determine wrap conditions
	if !in_area: return
	if moving: return
	if Global.move_count <= 0: 
		var n = str("The cauldron... refuses to move?")
		Global.smallnote.emit(n)
		return
	var p : AnimatableBody3D = get_tree().get_first_node_in_group("player")
	var dir = (global_position - p.global_position).normalized()
	dir = dir.snapped(Vector3.ONE)
	#print(dir)
	dir.y = 0
	
	ray.target_position = dir * tile_size * 1.25
	ray.force_raycast_update()
	if !ray.is_colliding():
		var tw = create_tween()
		tw.tween_property(self,"position",position + (dir * tile_size),1.0/anim_speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		moving = true
		Global.volatility += randf_range(0.01,0.1)
		if !Global.cheat_no_move_count:
			Global.move_count -= 1
		await tw.finished
		moving = false
	else:
		var tw = create_tween()
		tw.tween_property(self,"position",position + (dir * (tile_size/4)),0.5/anim_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self,"position",position,0.5/anim_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		moving = true
		#Global.sage_bounce.emit()
		await tw.finished
		moving = false

func shrink():
	await create_tween().tween_property(cmesh,"scale",Vector3.ZERO,0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).finished
func growout():
	await create_tween().tween_property(cmesh,"scale",Vector3.ONE,0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.1).finished

#var didflip := false
func flipx():
	#print("hi\n__\n")
	#if didflip: return
	#didflip = true
	await shrink()
	var newpos 
	if position.x < 0:
		newpos = -(position.x + tile_size)
	else: newpos = -(position.x - tile_size)
	position.x = newpos
	await growout()
	#didflip = false

func flipz():
	#print("hi\n__\n")
	#if didflip: return
	#didflip = true
	await shrink()
	var newpos 
	if position.z < 0:
		newpos = -(position.z + tile_size)
	else: newpos = -(position.z - tile_size)
	position.z = newpos
	growout()
	#didflip = false

var open := false
func _physics_process(delta):
	if Input.is_action_just_pressed("Interact") and in_area and Global.can_interact:
		match open:
			true: 
				Global.open_cauldron.emit(false)
				Global.fcam.emit(Vector3.ZERO)
			false: 
				Global.open_cauldron.emit(true)
				Global.eval_potion.emit(false)
				Global.fcam.emit(Vector3(global_position.x,0,global_position.z))
		open = !open

var in_area := false
func _on_area_3d_body_entered(_body):
	in_area = true

func _on_area_3d_body_exited(_body):
	in_area = false
	close_ui()

var sfx := true
func close_ui():
	if open: Global.fcam.emit(Vector3.ZERO)
	open = false
	sfx = false
	Global.open_cauldron.emit(false)
	await get_tree().create_timer(0.75).timeout
	sfx = true

func _on_plant_scope_body_entered(body):
	#print("plant in")
	if "plant_type" in body:
		body.range_state(true)
		match body.plant_type:
			0: #dsprt
				#print("dp")
				Global.conjure_level += 1
			1: #cflwr
				#print("cf")
				#Global.can_conjure = true
				conjures += 1

func _on_plant_scope_body_exited(body):
	#print("plant out")
	if "plant_type" in body:
		body.range_state(false)
		match body.plant_type:
			0: #dsprt
				Global.conjure_level -= 1
			1: #cflwr
				#Global.can_conjure = false
				conjures -= 1
