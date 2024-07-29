extends Control

@onready var newdisc = $VBoxContainer/newdisc
@onready var nddetail = $VBoxContainer/nddetail
@onready var burst = $burst

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var ntw : Tween
var nddt = [
	"has bloomed from the ether",
	"emerged from the void",
	"rose out of the abyss",
	"concentrated into existance",
	"bent space and time to appear here",
	"collidied into this reality",
	"burst through the ninth gate",
	"has fallen into position",
	"arrived in honor",
	"slipped past the gatekeepers",
	"popped into place",
	"renders onto the fabric",
	"folds out of the rend",
	"twists into reason",
	"washes out of the mist",
	"came to be",
	"redefined the universe around it",
	"climbs out of the end",
	"dropped through the veil",
	"reduced the fourth wall to ash"
]
func notify_new_disc(new_name : String,rxp):
	#greek, no iso
	print(new_name)
	if ntw: ntw.kill()
	ntw = create_tween()
	var pxsrt = get_tree().get_first_node_in_group("pxsort")
	var skwv = get_tree().get_first_node_in_group("skwv")
	newdisc.text = str("[center][pulse][wave]",new_name)
	nddetail.text = str("[center]",nddt.pick_random())
	nddetail.visible_ratio = 0
	ntw.tween_property(self,"position:y",96,0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	ntw.parallel().tween_property(pxsrt.material,"shader_parameter/sort",randf_range(1.2,2),0.2).set_ease(Tween.EASE_IN_OUT)
	SFXm.play("res://Assets/Sounds/679162__nkzelula__glitch-10.wav","sfx",randf_range(0.9,1.1))
	ntw.tween_property(pxsrt.material,"shader_parameter/sort",0.0,0.2).set_ease(Tween.EASE_IN_OUT)
	if new_name.contains("+") or new_name.contains("-"):
		#print("shockwave")
		ntw.parallel().tween_property(skwv.material,"shader_parameter/radius",1.0,1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		pshockwavesfx()
		ntw.parallel().tween_property(nddetail,"visible_ratio",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.2)
		ntw.parallel().tween_property(newdisc,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
	else:
		ntw.parallel().tween_property(nddetail,"visible_ratio",1,0.3).set_ease(Tween.EASE_IN_OUT).set_delay(0.5)
		ntw.parallel().tween_property(newdisc,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
	
	await ntw.finished
	burst.emitting = true
	SFXm.play("res://Assets/Sounds/170523__alexkandrell__royal-sparkle-whoosh-centre.wav","sfx",randf_range(0.9,1.1))
	var n = str("you performed [color=ff3399]",rxp,"[/color], congrats on the new discovery")
	Global.smallnote.emit(n)
	ntw = create_tween()
	ntw.tween_property(self,"position:y",-96,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(3)
	ntw.tween_property(newdisc,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
	skwv.material.set_shader_parameter("radius",0.0)

func pshockwavesfx():
	await get_tree().create_timer(0.35).timeout
	SFXm.play("res://Assets/Sounds/743008__silverillusionist__massive-laser-more-bass.wav","sfx",randf_range(0.9,1.1),0.8)
