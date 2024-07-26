extends Node3D

@onready var spirit_spr = $SpiritSpr

var spirits = {
	NOSPIRIT=3,
	FORGETFULNESS=0.2, #Reduces impurites (reduce tfc)
	MELANCHOLY=0.2, #Reduces volatility
	JUBILANT=0.2, #Increases volatility
	REMEDY=0.06, #Increases move count (rare)
	MISCHIEF=0.08, #Decreases move count (rare)
	LATIN=0.1, #Boost consume with A-Z
	HELLENIKE=0.1, #Boost consume with alpha-omega
	BRILLIANCE=0, #Provide hints
	SINISTER=0.1, #some dude who adds shadows
	LUMINOUS=0.1, #another which removes them
	NIMBLE=0.2, #increases how quickly shadows shift (reduce f_lim)
	LACKADASIC=0.2, #decreases how quickly shadows shift (increase f_lim
	AMICABLE=0.08, #increases the chances you have with the sentinel
	AUSTERE=0.2, #trys to wake the sentinel
	PIQUE=0.1, #tickles the shadows
	OMINOUS=0.05, #clears all spirits
	EXEMPLARY=0.05, #stacks a modifier that will increase consume if synergy is over 0.75
	PROMINENT=0.08, #sprits will double roll on no spirit (higher sprit chance essentially
	#ABUNDANCE #adds three random particles
	#PROVIDENCE #adds three random particles and three random alloys
	#DIVINE #(rare) reduces shadows in the well to 1
	#NEFARIOUS #(rare) increases shadows in the well to 25
}

var current
static var double := false

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.move_shadows.connect(set_do_nothing)
	Global.clear_spirits.connect(clear_spirit)

var do_nothing := false
func set_do_nothing():
	do_nothing = true
	await get_tree().create_timer(0.75).timeout
	do_nothing = false

func clear_spirit():
	current = spirits.keys()[0]
	fdisp(false)

func settle_spirit():
	if current == spirits.keys()[0] or do_nothing:
		return
	await get_tree().create_timer(0.15).timeout
	SFXm.play("res://Assets/Sounds/745961__argmantas__wobbly-bell.wav","master",randf_range(0.9,1.1))
	var n : String
	match current:
		"FORGETFULNESS": 
			Global.total_fusion_count -= clamp(randi_range(5,30),0,Global.total_fusion_count)
			n = str("[color=white]",current,"[/color] reduced the impurities in the cauldron")
		"MELANCHOLY":
			Global.volatility -= clamp(randf_range(2,6),0,Global.volatility)
			n = str("[color=white]",current,"[/color] quelled the flames excitement")
		"JUBILANT":
			Global.volatility += clamp(randf_range(1,2),0,Global.volatility)
			n = str("[color=white]",current,"[/color] amplified the flames beneath the cauldron")
		"REMEDY":
			Global.move_count += randi_range(8,18)
			n = str("[color=white]",current,"[/color] repaired the cauldron slightly")
		"MISCHIEF":
			Global.move_count -= randi_range(3,8)
			n = str("[color=white]",current,"[/color] damaged the cauldron slightly")
		"LATIN":
			Global.boost_latin = true
			n = str("[color=white]",current,"[/color] has given you their blessing")
		"HELLENIKE":
			Global.boost_greek = true
			n = str("[color=white]",current,"[/color] has given you their blessing")
		"BRILLIANCE":
			pass
		"SINISTER":
			Global.add_shadow.emit()
			n = str("[color=white]",current,"[/color] has darkened the well")
		"LUMINOUS":
			Global.remove_shadow.emit()
			n = str("[color=white]",current,"[/color] has brightened the well")
		"NIMBLE":
			if Global.fusion_lim != 1:
				Global.fusion_lim = clamp(Global.fusion_lim - randi_range(2,4),1,9999)
				n = str("[color=white]",current,"[/color] agitated the shadows")
			else: n = str("[color=white]",current,"[/color] tried to agitate the shadows")
		"LACKADASIC":
			Global.fusion_lim = clamp(Global.fusion_lim + randi_range(2,4),1,9999)
			n = str("[color=white]",current,"[/color] calmed the shadows")
		"AMICABLE":
			Global.sent_regen.emit()
			n = str("[color=white]",current,"[/color] whispered to the [color=white]sentinel[/color]")
		"AUSTERE":
			Global.wake_sent.emit()
			n = str("[color=white]",current,"[/color] tattled to the [color=white]sentinel[/color]")
		"PIQUE":
			Global.tickle_shadows.emit()
			n = str("[color=white]",current,"[/color] shifted the shadows")
		"OMINOUS":
			n = str("[color=white]",current,"[/color] scared everyone into the abyss")
			Global.clear_spirits.emit()
		"EXEMPLARY":
			Global.consume_mod += randi_range(0.02,0.12)
			n = str("[color=white]",current,"[/color] has given you their blessing")
		"PROMINENT":
			double = true
			n = str("[color=white]",current,"[/color] is gushing about you to the others")
	
	Global.smallnote.emit(n.to_lower())
	fdisp(false)
	current = spirits.keys()[0]

func roll_spirit():
	var total_Weight : float = 0
	for w in spirits:
		total_Weight += spirits[w]
	
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	var rol = rand.randf_range(0,total_Weight)
	for w in spirits:
		if rol < spirits[w]:
			return w
		rol -= spirits[w]
	return spirits.keys()[0]

func set_spiritB():
	if current == spirits.keys()[0]:
		set_spirit()

func set_spirit():
	var r = roll_spirit()
	if r == spirits.keys()[0] and double:
		r = roll_spirit()
	
	current = r
	print(r)
	if r != spirits.keys()[0]:
		appearance()
		if !hidden:
			await fdisp(false)
		fdisp(true)
		return
	else: fdisp(false)

func appearance():
	var A = [Rect2(0,0,128,256), Rect2(0,256,128,256)]
	var B = [Rect2(128,0,128,256), Rect2(128,256,128,256)]
	var C = [Rect2(256,0,128,256), Rect2(256,256,128,256)]
	var D = [Rect2(384,0,128,256), Rect2(384,256,128,256)]
	var E = [Rect2(512,0,128,256), Rect2(512,256,128,256)]
	var F = [Rect2(640,0,128,256), Rect2(640,256,128,256)]
	match current:
		"FORGETFULNESS": 
			spirit_spr.texture.region = A.pick_random()
			set_gradient(Color("#66ccff"))
		"MELANCHOLY":
			spirit_spr.texture.region = A.pick_random()
			set_gradient(Color("#1f4799"))
		"JUBILANT":
			spirit_spr.texture.region = B.pick_random()
			set_gradient(Color("#ffd500"))
		"REMEDY":
			spirit_spr.texture.region = B.pick_random()
			set_gradient(Color("#f27900"))
		"MISCHIEF":
			spirit_spr.texture.region = B.pick_random()
			set_gradient(Color("#ff3399"))
		"LATIN":
			spirit_spr.texture.region = C.pick_random()
			set_gradient(Color("#fff9f2"))
		"HELLENIKE":
			spirit_spr.texture.region = C.pick_random()
			set_gradient(Color("#fff9f2"))
		"BRILLIANCE":
			spirit_spr.texture.region = A.pick_random()
			set_gradient(Color.WHITE)
		"SINISTER":
			spirit_spr.texture.region = C.pick_random()
			set_gradient(Color("#ff3399"))
		"LUMINOUS":
			spirit_spr.texture.region = A.pick_random()
			set_gradient(Color("#ffff4d"))
		"NIMBLE":
			spirit_spr.texture.region = A.pick_random()
			set_gradient(Color("#f27900"))
		"LACKADASIC":
			spirit_spr.texture.region = A.pick_random()
			set_gradient(Color("#ff8095"))
		"AMICABLE":
			spirit_spr.texture.region = E.pick_random()
			set_gradient(Color("#f27900"))
		"AUSTERE":
			spirit_spr.texture.region = F.pick_random()
			set_gradient(Color("#ffff4d"))
		"PIQUE":
			spirit_spr.texture.region = D.pick_random()
			set_gradient(Color("#ff8095"))
		"OMINOUS":
			spirit_spr.texture.region = E.pick_random()
			set_gradient(Color("#fff9f2"))
		"EXEMPLARY":
			spirit_spr.texture.region = D.pick_random()
			set_gradient(Color("#fff9f2"))
		"PROMINENT":
			spirit_spr.texture.region = E.pick_random()
			set_gradient(Color("#ffd500"))
		
	if spirit_spr.texture.region.position.y == 256:
		spirit_spr.material_override.set_shader_parameter("offsetuv",0.5)
	else: spirit_spr.material_override.set_shader_parameter("offsetuv",0.0)

func set_gradient(top_color : Color):
	var grd := Gradient.new()
	grd.colors = [Color("#ffffff00"),top_color]
	var cg : GradientTexture2D = spirit_spr.material_override.get_shader_parameter("colorgrad")
	cg.gradient = grd
	spirit_spr.material_override.set_shader_parameter("colorgrad",cg)

var ftw : Tween
var hidden : bool
func fdisp(s:bool):
	if ftw: ftw.kill()
	ftw = create_tween()
	match s:
		true:
			ftw.tween_property(spirit_spr.material_override,"shader_parameter/alpha",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
			hidden = false
			await ftw.finished
		false:
			ftw.tween_property(spirit_spr.material_override,"shader_parameter/alpha",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
			hidden = true
			await ftw.finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var btw : Tween
func _on_area_3d_body_entered(body):
	if current != spirits.keys()[0] and !do_nothing:
		Global.smallnote.emit(str("you've approached [color=white]",current).to_lower())
		SFXm.play("res://Assets/Sounds/541887__d4xx__pop-up-sound.wav","master",randf_range(0.9,1.1))
		if btw and btw.is_running(): 
			await btw.finished
		elif btw: btw.kill()
		btw = create_tween()
		btw.tween_property(self,"position:y",position.y + 0.5,0.15).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		btw.tween_property(self,"position:y",position.y,0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
