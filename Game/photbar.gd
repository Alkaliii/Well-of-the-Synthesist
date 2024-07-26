extends HBoxContainer

var in_hotbar : Array[Mixture] = []

@onready var positions = [$Potion, $Middle/Potion2, $Middle/Potion3, $Potion4]

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.add_potion.connect(add_potion)
	Global.remove_potion.connect(remove_potion)
	Global.open_cauldron.connect(s_on_c)

func s_on_c(s : bool):
	subtle(s)

func update():
	print(in_hotbar)
	for p in positions:
		if positions.find(p) == positions.size() - 1:
			await p.fdisp(false)
		else:
			p.fdisp(false)
	for i in in_hotbar:
		var d = positions[in_hotbar.find(i)]
		d.what_ami = i
		d.set_appearance()
		d.fdisp(true)

func add_potion(m : Mixture):
	in_hotbar.append(m)
	Global.discovered.append(m.get_nameb())
	var disp = positions[in_hotbar.find(m)]
	disp.what_ami = m
	disp.set_appearance()
	disp.fdisp(true)

func remove_potion(m : Mixture):
	var disp = positions[in_hotbar.find(m)]
	var doupdate := true
	if in_hotbar.find(m) == in_hotbar.size():
		doupdate = false
	disp.what_ami = null
	in_hotbar.erase(m)
	#await disp.fdisp(false)
	if doupdate: update()

var tws : Tween
func subtle(s : bool):
	if get_tree() == null: return
	if tws: tws.kill()
	tws = create_tween()
	match s:
		true: #ON
			for i in positions:
				i.flake(false)
			tws.tween_property(self,"modulate:a",0.2,0.25).set_ease(Tween.EASE_IN_OUT)
		false:
			for i in positions:
				i.flake(true)
			tws.tween_property(self,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
