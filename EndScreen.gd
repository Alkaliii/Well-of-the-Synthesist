extends Control

@export var debug := false

@onready var ss = $GameOverview/MarginContainer/HBoxContainer/VBoxContainer/ss
@onready var fs = $GameOverview/MarginContainer/HBoxContainer/VBoxContainer/fs

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	outro()
	if Global.consumed_mixture:
		fs.text = str("FINAL SCORE:[wave] ",snapped(await Global.consumed_mixture.calculate_value(),0.01))
	if Global.used_cheats: 
		ss.disabled = true
		ss.text = "invalid score"
	leaderboard.disp_lb()

@onready var bt = $bt
@onready var tvb = $bt/t
@onready var tip = $bt/t/tip
@onready var ltxt = $bt/t/ltxt
@onready var game_overview = $GameOverview

var itw : Tween
const ee = [
	"and your heart races.",
	"and the world folds.",
	"and your body tingles.",
	"and you feel at ease.",
	"and your mind slows.",
	"and a calm washes over you.",
	"and the whispers stop.",
	"and everything appears sharper.",
	"and everything appears saturated.",
	"and you start to feel different.",
	"and you still feel the same.",
	"and the sentinel scoffs.",
	"and the spirits squeal.",
	"and it all comes together.",
	"and your hands tremble.",
	"and you shed a tear.",
	"and your fears ease a little.",
	"and the aches lets up.",
	"and the spinning stops."
]
func outro():
	tip.text = str("You take a sip of the elixir")
	ltxt.text = ee.pick_random()
	itw = create_tween()
	#play_delayed_hush(0,2.8)
	#itw.tween_property(bt,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	itw.tween_property(tvb,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	tip.text = str("Quickly, you ascend the mountain")
	ltxt.text = "the climb was perilous."
	itw = create_tween()
	#SFXm.play("res://Assets/Sounds/hushA.wav","master",randf_range(0.9,1.1))
	itw.tween_property(tvb,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.25)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	itw.parallel().tween_property(bt,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	tip.text = str("\"Master, I've returned\"")
	ltxt.text = "your voice echos into the winds"
	itw = create_tween()
	itw.tween_property(bt,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	itw.tween_property(tvb,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.25)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	#spawn edith
	var ese = get_tree().get_first_node_in_group("ese")
	if ese: ese.show()
	tip.text = str(Global.player_name,"?")
	ltxt.text = "..."
	itw = create_tween()
	itw.tween_property(tvb,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.25)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	itw.parallel().tween_property(bt,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	tip.text = str("\"I've brought you more medicine\"")
	ltxt.text = "you raise the elixir"
	itw = create_tween()
	itw.tween_property(bt,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	itw.tween_property(tvb,"modulate:a",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.25)
	itw.tween_property(tvb,"modulate:a",0,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(3.0)
	await itw.finished
	game_overview.show()
	itw = create_tween()
	itw.tween_property(game_overview,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)

func _on_ts_pressed():
	Global.reset()
	if !SFXm.looping.is_empty():
		for l in SFXm.loop_paths:
			SFXm.stop_loop(l)
	get_tree().get_first_node_in_group("ldr").loadnew("res://Game/title_screen.tscn")

func _on_pa_pressed():
	Global.reset()
	if !SFXm.looping.is_empty():
		for l in SFXm.loop_paths:
			SFXm.stop_loop(l)
	get_tree().get_first_node_in_group("ldr").loadnew("res://Game/game.tscn",true)

@onready var leaderboard = $GameOverview/MarginContainer/HBoxContainer/Leaderboard
func _on_ss_pressed():
	ss.disabled = true
	ss.text = "submitted"
	var m : Mixture
	var player_name : String
	var score : float
	var mixture : String
	var sum : String
	if Global.consumed_mixture:
		m = Global.consumed_mixture
		player_name = Global.player_name.strip_edges(true,true).to_upper().replace(" ","_")
		score = await m.calculate_value()
		if Global.boost_greek and m.has_greek():
			score *= 0.2
		if Global.boost_latin and m.has_latin():
			score *= 0.2
		
		mixture = m.get_nameg(true)
		sum = str("(",m.m1.particle + 1,"+",m.m2.particleA + 1,"+",m.m2.particleB + 1,")")
	elif debug:
		m = Mixture.get_random()
		player_name = Global.player_name.strip_edges(true,true).to_upper().replace(" ","_")
		score = await m.calculate_value()
		mixture = m.get_nameg(true)
		sum = str("(",m.m1.particle + 1,"+",m.m2.particleA + 1,"+",m.m2.particleB + 1,")")
	
	leaderboard.submit_score({"mixture" : mixture,"player_name" : player_name, "score" : score, "sum" : sum})
