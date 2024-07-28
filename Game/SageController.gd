extends AnimatableBody3D

@export var anim_speed := 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var ray = $RayA
@onready var sprite_3d = $Sprite3D

var msgbox : msgbx

var tile_size = 1.6
var inputs = {
	"move_right": Vector3.RIGHT,
	"move_left": Vector3.LEFT,
	"move_up": Vector3.FORWARD,
	"move_down": Vector3.BACK
}

@onready var custom_sage = $CustomSage
func _ready():
	set_physics_process(false)
	if Global.player_shader:
		custom_sage.material_override = Global.player_shader
	snap_in()
	position.y = 0.1
	
	await get_tree().create_timer(1.75).timeout
	await get_tree().process_frame
	msgbox = get_tree().get_first_node_in_group("msgbox")
	if msgbox:
		Global.zcam.emit(6)
		Global.fcam.emit(global_position)
		msgbox.position.y = 0
		await get_tree().create_timer(0.25).timeout
		await msgbox.play_msg("...",1.5)
		await msgbox.play_msg("it's still here...")
		Global.zcam.emit(12)
		Global.fcam.emit(Vector3.ZERO)
	set_physics_process(true)

func snap_in():
	position = position.snapped(Vector3.ONE * tile_size)
	position += Vector3.ONE * (tile_size/2)

#func _unhandled_input(event):

func _physics_process(delta):
	if moving:
		return
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			move(dir)

var moving := false
func move(dir):
	match dir:
		"move_right":
			sprite_3d.flip_h = true
			custom_sage.scale.x = -1
		"move_down":
			sprite_3d.flip_h = false
			custom_sage.scale.x = 1
	
	ray.target_position = inputs[dir] * tile_size * 1.25
	ray.force_raycast_update()
	if !ray.is_colliding():
		var tw = create_tween()
		tw.tween_property(self,"position",position + (inputs[dir] * tile_size),1.0/anim_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		moving = true
		SFXm.play("res://Assets/Sounds/footstep09.ogg","master",randf_range(0.9,1.1),0.2)
		await tw.finished
		moving = false
	else:
		var tw = create_tween()
		tw.tween_property(self,"position",position + (inputs[dir] * (tile_size/4)),0.5/anim_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self,"position",position,0.5/anim_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		moving = true
		SFXm.play("res://Assets/Sounds/bonk.wav","master",randf_range(0.9,1.1),0.4)
		Global.sage_bounce.emit()
		await tw.finished
		moving = false

#func _physics_process(delta):
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
