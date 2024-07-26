extends PanelContainer

@export var bottle : int = 0 : set = set_bottle
@export var debug := false

@onready var liquid_spr = $liquid
@onready var extra_spr = $extra
@onready var bottle_spr = $bottle
@onready var p_1 = $p1
@onready var p_2 = $p2
@onready var p_3 = $p3
@onready var btn = $Button

var what_ami : Mixture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	if debug:
		what_ami = Mixture.get_random()
		print(what_ami.get_namegb())
		set_appearance()

func set_appearance():
	#0.45 - 0.52
	liquid_spr.material.set_shader_parameter("progress",randf_range(0.45,0.52))
	var gradnt := Gradient.new()
	var c1 := Element.get_particle_color(what_ami.m1.particle)
	var c2 := Element.get_particle_color(what_ami.m2.particleA)
	var c3 := Element.get_particle_color(what_ami.m2.particleB)
	gradnt.colors = PackedColorArray([c1,c2,c3])
	gradnt.offsets = PackedFloat32Array([0,randf_range(0.4,0.5),1.0])
	var g : GradientTexture2D = liquid_spr.material.get_shader_parameter("gradient_overlay")
	g.gradient = gradnt
	liquid_spr.material.set_shader_parameter("gradient_overlay",g)
	
	var psum = what_ami.m1.particle + what_ami.m2.particleA + what_ami.m2.particleB
	var tsum = what_ami.m1.tier + what_ami.m2.tier
	var new_bottle = (psum + tsum) % 5
	
	#print(what_ami.m1.get_nameb())
	p_1.texture.region = Element.get_particle_icon(what_ami.m1.particle)
	p_2.texture.region = Element.get_particle_icon(what_ami.m2.particleA)
	p_3.texture.region = Element.get_particle_icon(what_ami.m2.particleB)
	
	set_bottle(new_bottle)

func set_bottle(b : int):
	bottle = b
	var pos = float(b * 192)
	if liquid_spr:
		liquid_spr.texture.region = Rect2(pos,192,192,192)
	if extra_spr:
		extra_spr.texture.region = Rect2(pos,384,192,192)
	if bottle_spr:
		bottle_spr.texture.region = Rect2(pos,0,192,192)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	#print("hi")
	#print(what_ami.get_nameb())
	btn.release_focus()
	
	var pv = get_tree().get_first_node_in_group("pval")
	if pv.state and pv.viewing != what_ami:
		Global.eval_potion.emit(false)
		Global.eval_potion.emit(true,what_ami)
		print(0)
	elif pv.state and pv.viewing == what_ami:
		Global.eval_potion.emit(false)
		print(1)
	else:
		Global.eval_potion.emit(true,what_ami)
		print(2)
	#Open Eval
	#on eval
	# Sell
	# Discard
	# Consume

var twhv : Tween
func hover(s : bool):
	if twhv: twhv.kill()
	twhv = create_tween()
	pivot_offset = size/2
	match s:
		true:
			twhv.tween_property(self,"scale",Vector2(1.3,1.3),0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		false:
			twhv.tween_property(self,"scale",Vector2.ONE,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

var twf : Tween
func fdisp(s : bool):
	if twf: twf.kill()
	twf = create_tween()
	match s:
		true:
			btn.disabled = !p_4.emitting
			twf.tween_property(self,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
		false:
			btn.disabled = true
			twf.tween_property(self,"modulate:a",0,0.25).set_ease(Tween.EASE_IN_OUT)
	await twf.finished

@onready var p_4 = $p4
func flake(s : bool):
	p_4.emitting = s
	btn.disabled = !s

func _on_button_mouse_entered():
	hover(true)

func _on_button_mouse_exited():
	hover(false)
