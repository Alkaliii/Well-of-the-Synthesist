extends PanelContainer

@onready var combinationid = $VBoxContainer/Panel/VBoxContainer/combinationid
@onready var element_name = $VBoxContainer/Panel/VBoxContainer/ElementName

@onready var stats = $VBoxContainer/Panel/VBoxContainer/stats
#Need spellbook furniture to see stats
@onready var value = $VBoxContainer/Panel/VBoxContainer/stats/value/value
@onready var syn = $VBoxContainer/Panel/VBoxContainer/stats/syn/syn
@onready var align = $VBoxContainer/Panel/VBoxContainer/stats/align/align
@onready var impure = $VBoxContainer/Panel/VBoxContainer/stats/impure/impure

@onready var hypersat = $VBoxContainer/Panel/VBoxContainer/Penalties/hypersat
@onready var oversat = $VBoxContainer/Panel/VBoxContainer/Penalties/oversat

@onready var grdnt = $VBoxContainer/grdnt

@onready var m_1 = $VBoxContainer/Panel/VBoxContainer/icns/m1
@onready var m_2a = $VBoxContainer/Panel/VBoxContainer/icns/m2a
@onready var m_2b = $VBoxContainer/Panel/VBoxContainer/icns/m2b



var state := false
var viewing : Mixture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	Global.eval_potion.connect(open)

func open(s : bool, m : Mixture = null):
	fdisp(s)
	if m: set_eval(m)

var ftw : Tween
func fdisp(s:bool):
	if ftw and ftw.is_running(): 
		await ftw.finished
		ftw.kill()
	elif ftw: ftw.kill()
	ftw = create_tween()
	match s:
		true:
			#Global.force_close_cauldron.emit()
			show()
			ftw.tween_property(self,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
			state = true
		false:
			ftw.tween_property(self,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
			state = false
			await ftw.finished
			hide()

func set_eval(m : Mixture):
	viewing = m
	combinationid.text = str(m.m1.particle + 1,"+",m.m2.particleA + 1,"+",m.m2.particleB + 1," [color=777777]/ ",m.m1.tier,"+",m.m2.tier)
	element_name.text = m.get_nameg(true)
	
	m_1.texture.region = Element.get_particle_icon(m.m1.particle)
	m_2a.texture.region = Element.get_particle_icon(m.m2.particleA)
	m_2b.texture.region = Element.get_particle_icon(m.m2.particleB)
	
	var gradnt := Gradient.new()
	var c1 := Element.get_particle_color(m.m1.particle)
	var c2 := Element.get_particle_color(m.m2.particleA)
	var c3 := Element.get_particle_color(m.m2.particleB)
	gradnt.colors = PackedColorArray([c1,c2,c3])
	gradnt.offsets = PackedFloat32Array([0,randf_range(0.4,0.5),0.9])
	grdnt.texture.gradient = gradnt
	
	hypersat.visible = m.hypersaturated()
	oversat.visible = m.oversaturated()
	
	if true: #check for spellbook
		value.text = str(snapped(await m.calculate_value(),0.01))
		syn.text = str(snapped(await m.get_synergy(m.m1.tier + m.m2.tier),0.01))
		align.text = str(m.is_aligned()).replace("true","YES").replace("false","NO")
		impure.text = str(snapped(m.impurities / 2,0.01),"ppm")
		stats.show()
	else:
		stats.hide()

func _on_dispose_pressed():
	Global.remove_potion.emit(viewing)
	Global.eval_potion.emit(false)

func _on_rouse_pressed():
	Global.remove_potion.emit(viewing)
	Global.eval_potion.emit(false)
	Global.smallnote.emit("the spirits within the shadows shift")
	await get_tree().create_timer(0.25).timeout
	Global.rouse_shadows.emit()
	await get_tree().process_frame
	if [true,false,false].pick_random(): Global.move_shadows.emit()
