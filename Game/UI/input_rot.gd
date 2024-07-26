extends HBoxContainer
class_name crotinput

@onready var lbl = $lbl
@onready var line_edit = $Rot/LineEdit
@onready var slider = $Rot/slider

@export var label := "Rotation"
@export var default :float= 90
@export var range_settings := Vector3(0,100,1) #Min,Max,Step

signal new_value

# Called when the node enters the scene tree for the first time.
func _ready():
	slider.min_value = range_settings.x
	line_edit.min_value = range_settings.x
	slider.max_value = range_settings.y
	line_edit.max_value = range_settings.y
	slider.step = range_settings.z
	line_edit.step = range_settings.z
	slider.value = default
	line_edit.value = default
	lbl.text = str("[right]",label)

func _process(delta):
	if Input.is_action_just_pressed("ui_text_submit"):
		if line_edit.get_line_edit().has_focus(): line_edit.get_line_edit().release_focus()

func reset():
	slider.value = default
	slider.value_changed.emit(slider.value)

func _on_line_edit_value_changed(value):
	#emit signal?
	if slider.value != value:
		slider.value = value
	#line_edit.get_line_edit().release_focus()
	new_value.emit(value)
	pass

func _on_slider_drag_ended(value_changed):
	if value_changed:
		line_edit.value = slider.value

func _on_slider_value_changed(value):
	if line_edit.value != value:
		line_edit.value = value
