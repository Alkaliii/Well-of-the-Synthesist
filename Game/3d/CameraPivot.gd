extends Node3D
class_name MainGameCamera

@onready var camera_3d = $Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.fcam.connect(focus_position)
	Global.zcam.connect(zoom_position)

var cttw : Tween
func focus_position(pos : Vector3):
	if pos == global_position: return
	print("focusing on ",pos)
	if cttw: cttw.kill()
	cttw = create_tween()
	cttw.tween_property(self,"global_position",pos,0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

var zttw : Tween
func zoom_position(nz : float): #default 12
	if camera_3d.size == nz: return
	print("zooming in: ",nz)
	if zttw: zttw.kill()
	zttw = create_tween()
	zttw.tween_property(camera_3d,"size",nz,0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pro2Dto3D(input : Vector2) -> Vector3:
	return camera_3d.project_position(input,15)

func upro3Dto2D(input : Vector3) -> Vector2:
	return camera_3d.unproject_position(input)
