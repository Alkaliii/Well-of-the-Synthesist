extends Node

@export var inputs_col : ccolorpicker
@export var inputs_rot : crotinput
@export var inputs_scale : cvec2input
@export var inputs_pos : cvec2input
@export var which_eye : String = "eyeA"
@export var edit : MeshInstance3D

func _ready():
	if inputs_col: inputs_col.new_value.connect(set_eye)
	if inputs_rot: inputs_rot.new_value.connect(set_eye)
	if inputs_scale: inputs_scale.new_value.connect(set_eye_scale)
	if inputs_pos: inputs_pos.new_value.connect(set_eye_position)

func set_eye(value):
	if !edit: return
	if value is String:
		create_tween().tween_property(edit.material_override,str("shader_parameter/",which_eye,"_col"),Color(value),0.25).set_ease(Tween.EASE_IN_OUT)
		#edit.set_shader_parameter(str(which_eye,"_col"),value)
	else:
		edit.material_override.set_shader_parameter(str(which_eye,"_rot"),value)

func set_eye_scale(value):
	if !edit: return
	edit.material_override.set_shader_parameter(str(which_eye,"_scale"),value)

func set_eye_position(value):
	if !edit: return
	edit.material_override.set_shader_parameter(str(which_eye,"_translate"),value)
