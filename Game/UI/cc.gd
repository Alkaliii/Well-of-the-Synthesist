extends Control

@export var edit : MeshInstance3D
@onready var name_lineedit = $VBoxContainer/TextInput/name_lineedit
@onready var all_pickers : Array[Control] = [$VBoxContainer/v/colors/ccPickColor, $VBoxContainer/v/colors/hcPickColor, $VBoxContainer/v/eyes/EyeA/eaPickColor, $VBoxContainer/v/eyes/EyeA/eaRot, $VBoxContainer/v/eyes/EyeA/eaVec2p, $VBoxContainer/v/eyes/EyeA/eaVec2s, $VBoxContainer/v/eyes/EyeB/ebPickColor, $VBoxContainer/v/eyes/EyeB/ebRot, $VBoxContainer/v/eyes/EyeB/ebVec2p, $VBoxContainer/v/eyes/EyeB/ebVec2s, $VBoxContainer/v/eyes/EyeC/ecPickColor, $VBoxContainer/v/eyes/EyeC/ecRot, $VBoxContainer/v/eyes/EyeC/ecVec2p, $VBoxContainer/v/eyes/EyeC/ecVec2s]

@onready var eye_edits = [$SetEyeA, $SetEyeB, $SetEyeC]
@onready var cc_pick_color = $VBoxContainer/v/colors/ccPickColor
@onready var hc_pick_color = $VBoxContainer/v/colors/hcPickColor
@onready var reset = $VBoxContainer/TextInput/reset

# Called when the node enters the scene tree for the first time.
func _ready():
	for e in eye_edits:
		e.edit = edit
	
	name_lineedit.placeholder_text = default_names.pick_random()
	cc_pick_color.new_value.connect(set_cloak)
	hc_pick_color.new_value.connect(set_hood)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@onready var lbl_2 = $VBoxContainer/TextInput/lbl2

const default_names := ["Yiev","Sara","Lucy","James","Arlo","Rusi","Kiel","Opal","Cujo"]
const easter_eggs := ["thor","aiwi","edith","pirate","edward","elric","senku","ishigami","erina","nakiri","bell","cranel","you"]
func _on_name_lineedit_text_submitted(new_text : String):
	if new_text:
		Global.player_name = new_text
		name_lineedit.release_focus()
		if new_text.strip_edges().to_lower() in easter_eggs:
			match new_text.strip_edges().to_lower():
				"thor": lbl_2.text = str("[center][wave][color=8cff19]The Captain")
				"aiwi": lbl_2.text = str("[center][wave][color=ff3399]Content Synthesist")
				"edith": lbl_2.text = str("[center][wave][color=66ccff]Grandmaster Synthesist")
				"pirate": lbl_2.text = str("[center][wave][color=8cff19]Skilled Scallywag")
				"edward": lbl_2.text = str("[center][wave][color=b3001e]Fullmetal Synthesist")
				"elric": lbl_2.text = str("[center][wave][color=b3001e]Fullmetal Synthesist")
				"senku": lbl_2.text = str("[center][wave][color=ff3399]Genius Synthesist")
				"ishigami": lbl_2.text = str("[center][wave][color=ff3399]Genius Synthesist")
				"erina": lbl_2.text = str("[center][wave][color=f27900]God's Synthesist")
				"nakiri": lbl_2.text = str("[center][wave][color=f27900]God's Synthesist")
				"bell": lbl_2.text = str("[center][wave][color=2e8ae6]Rookie Synthesist")
				"cranel": lbl_2.text = str("[center][wave][color=2e8ae6]Rookie Synthesist")
				"you": lbl_2.text = str("[center][wave]Apprentice Synthesist")
		#[center][wave]Apprentice Synthesist
	else: Global.player_name = name_lineedit.placeholder_text

func set_cloak(value):
	#tween?
	create_tween().tween_property(edit.material_override,"shader_parameter/cloak_col",Color(value),0.25).set_ease(Tween.EASE_IN_OUT)
	#print("hi",value)
	#edit.material_override.set_shader_parameter("cloak_col",Color(value))

func set_hood(value):
	#tween?
	create_tween().tween_property(edit.material_override,"shader_parameter/hood_col",Color(value),0.25).set_ease(Tween.EASE_IN_OUT)
	#edit.set_shader_parameter("hood_col",value)

func _on_reset_pressed():
	reset.release_focus()
	for i in all_pickers:
		i.reset()
