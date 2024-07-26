extends Node3D

@export var debug := false
@export var limits = Vector2(-2,2)

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug: 
		testA()
	
	for i in get_children():
		var offset = Vector2(randf_range(-30,30),randf_range(-30,30))
		i.material_override.set_shader_parameter("time_offset",offset)
		i.material_override.set_shader_parameter("speed",Vector2(0.01,randf_range(-0.2,0.2)))
		i.mesh.radial_segments = randi_range(4,7)
		await get_tree().process_frame
	
	Global.move_shadows.connect(move_shadows)
	Global.add_shadow.connect(add_shadow)
	Global.remove_shadow.connect(remove_shadow)
	Global.move_shadows.emit()

func testA():
	move_shadows()
	get_tree().create_timer(5).timeout.connect(testA)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

const SHADOW_BOX = preload("res://Game/3d/shadow_box.tscn")
func add_shadow():
	var new = SHADOW_BOX.instantiate()
	add_child(new)
	new.position.y = 2
	var offset = Vector2(randf_range(-30,30),randf_range(-30,30))
	new.material_override.set_shader_parameter("time_offset",offset)
	new.material_override.set_shader_parameter("speed",Vector2(0.01,randf_range(-0.2,0.2)))
	new.mesh.radial_segments = randi_range(4,7)
	Global.move_shadows.emit()

func remove_shadow():
	var c = get_children()
	var remove = c.pick_random()
	var rpos = [Vector2(9,9),Vector2(9,-9),Vector2(-9,9),Vector2(-9,-9)]
	await remove.move_to(rpos.pick_random())
	remove_child(remove)
	remove.queue_free()

func move_shadows():
	await get_tree().create_timer(0.25).timeout
	var npos = []
	while npos.size() < get_child_count():
		var rp = Vector2(randi_range(limits.x,limits.y),randi_range(limits.x,limits.y))
		if npos.has(rp): continue
		else: npos.append(rp)
		
		if npos.size() > get_child_count(): break
	
	var c = get_children()
	for i in c:
		i.move_to(npos[c.find(i)])
