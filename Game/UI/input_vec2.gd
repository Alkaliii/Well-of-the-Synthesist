extends HBoxContainer
class_name cvec2input

@export var label := "Position"
@export var default := Vector2.ZERO
@export var x_range_settings := Vector3(0,100,1) #Min,Max,Step
@export var y_range_settings := Vector3(0,100,1) #Min,Max,Step

@onready var lbl = $lbl
@onready var x = $x
@onready var y = $y

signal new_value

# Called when the node enters the scene tree for the first time.
func _ready():
	lbl.text = str("[right]",label)
	x.min_value = x_range_settings.x
	x.max_value = x_range_settings.y
	x.step = x_range_settings.z
	y.min_value = y_range_settings.x
	y.max_value = y_range_settings.y
	y.step = y_range_settings.z
	x.value = default.x
	y.value = default.y

func _process(delta):
	if Input.is_action_just_pressed("ui_text_submit"):
		if x.get_line_edit().has_focus(): x.get_line_edit().release_focus()
		if y.get_line_edit().has_focus(): y.get_line_edit().release_focus()

func reset():
	x.value = default.x
	y.value = default.y
	_on_y_value_changed(y.value)

func _on_y_value_changed(value):
	if value and x.value:
		new_value.emit(Vector2(x.value,y.value))

func _on_x_value_changed(value):
	if value and y.value:
		new_value.emit(Vector2(x.value,y.value))
