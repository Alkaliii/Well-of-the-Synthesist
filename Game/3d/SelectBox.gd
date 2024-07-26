extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var cam : MainGameCamera
var mtrack : Control
var tile_size = 1.6
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !cam: cam = get_tree().get_first_node_in_group("cam")
	if !mtrack: mtrack = get_tree().get_first_node_in_group("mtrack")
	
	if cam and mtrack:
		position = cam.pro2Dto3D(mtrack.get_global_mouse_position())
		snap_in()

func snap_in():
	position = position.snapped(Vector3(1,1,1) * tile_size)
	position += Vector3(1,1,1) * (tile_size/2)
