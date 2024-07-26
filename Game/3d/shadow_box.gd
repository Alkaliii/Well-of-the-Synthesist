extends MeshInstance3D



var tile_size = 1.6
@export var limits = Vector2(-2,2)
@export var debug := false
# Called when the node enters the scene tree for the first time.
func _ready():
	if debug: test_A()
	Global.rouse_shadows.connect(set_spirit)
	Global.tickle_shadows.connect(set_spiritB)
	#set_spirit()
	spirit.current = "NOSPIRIT"
	spirit.fdisp(false)

func test_A():
	await move_random()
	get_tree().create_timer(2).timeout.connect(test_A)

@onready var spirit = $Spirit
func set_spirit():
	if !inside: spirit.set_spirit()

func set_spiritB():
	if !inside: spirit.set_spiritB()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var inside := false
func _on_area_3d_body_entered(body):
	if "in_shadow" in body:
		body.in_shadow += 1
		if spirit.current != "NOSPIRIT":
			spirit.settle_spirit()
		inside = true

func _on_area_3d_body_exited(body):
	if "in_shadow" in body:
		body.in_shadow -= 1
		inside = false

func move_random():
	var newpos = Vector3(randi_range(limits.x,limits.y),0,randi_range(limits.x,limits.y)) * tile_size
	newpos.snapped(Vector3.ONE * tile_size)
	newpos += Vector3.ONE * (tile_size/2)
	newpos.y = position.y
	var tw = create_tween()
	tw.tween_property(self,"position",newpos,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tw.finished

func move_to(gridpos : Vector2):
	var newpos = Vector3(gridpos.x,0,gridpos.y) * tile_size
	newpos.snapped(Vector3.ONE * tile_size)
	newpos += Vector3.ONE * (tile_size/2)
	newpos.y = position.y
	var tw = create_tween()
	tw.tween_property(self,"position",newpos,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tw.finished
