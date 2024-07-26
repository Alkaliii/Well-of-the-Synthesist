extends HBoxContainer
class_name ccolorpicker

@onready var qcoptions = $qcb/QuickColor/Options
@onready var quick_color = $qcb/QuickColor
@onready var qcb = $qcb
@onready var lbl = $lbl
@onready var line_edit = $LineEdit

@export var label := "Color"
@export var default := "#FFFFFF"

signal new_value

# Called when the node enters the scene tree for the first time.
func _ready():
	lbl.text = str("[right]",label)
	line_edit.placeholder_text = default
	
	line_edit.text_changed.connect(on_change)
	line_edit.text_submitted.connect(on_change)
	line_edit.text_submitted.connect(defoc)
	
	var qcc = qcoptions.get_children()
	for i : Button in qcc:
		i.pressed.connect(quick_piq)
		if qcc.find(i) == 32: break
		i.icon = i.icon.duplicate()
		i.icon.region = Rect2(128 * qcc.find(i),0,128,128)

func reset():
	line_edit.text = str(default)
	line_edit.text_changed.emit(line_edit.text)

func on_change(s : String):
	#emit signal if valid?
	if s.is_valid_html_color(): 
		new_value.emit(s)
		qcb.icon = CBTN_4X
		qcb.modulate = Color(s)

func defoc(_s : String):
	if line_edit.text and line_edit.text[0] != "#":
		line_edit.text = str("#",line_edit.text)
	line_edit.release_focus()

const CBTN_4X = preload("res://Assets/Graphics/cbtn@4x.png")
func quick_piq():
	var f
	var qcc = qcoptions.get_children()
	for i : Button in qcc:
		if i.has_focus():
			f = qcc.find(i)
			if f != 32:
				var pos = Vector2(64,64)
				line_edit.text = str("#",i.icon.get_image().get_pixel(pos.x,pos.y).to_html(false))
				qcb.icon = CBTN_4X
				qcb.modulate = Color(line_edit.text)
				line_edit.text_changed.emit(line_edit.text)
			else: 
				line_edit.text = "#00000000"
				line_edit.text_changed.emit(line_edit.text)
				qcb.icon = i.icon
				qcb.modulate = Color.WHITE
			i.release_focus()
			
			quick_color.hide()
			break
			#close panel?
	print(f)

func _on_qcb_pressed():
	qcb.release_focus()
	quick_color.top_level = true
	quick_color.position = Vector2(64,(get_window().size.y / 2) - (quick_color.size.y / 2))
	quick_color.visible = !quick_color.visible
