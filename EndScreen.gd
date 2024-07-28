extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	outro()

@onready var bt = $bt
@onready var tvb = $bt/t
@onready var tip = $bt/t/tip
@onready var ltxt = $bt/t/ltxt
@onready var titlecam = $D3SVC/SV/env/titlecam
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
