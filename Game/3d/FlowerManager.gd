extends Node3D

@export var debug := false
@export var limits = Vector2(-2,2)
@export var dlimits = Vector2(-3,3)

@onready var conjures = $Conjures
@onready var densitysprouts = $Densitysprouts

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.move_shadows.connect(move_densities)
	Global.respawn_conjure.connect(move_conjures)
	if debug:
		testA()
	else: 
		await get_tree().process_frame
		move_conjures()

func testA():
	if [true,false].pick_random():
		move_conjures()
	else:
		move_densities()
	get_tree().create_timer(5).timeout.connect(testA)

var used_positions_d := []
var used_positions_c := []
var forbidden_positions := [Vector2(-2,-2)]
func move_densities():
	await get_tree().create_timer(0.25).timeout
	used_positions_d.clear()
	while used_positions_d.size() < densitysprouts.get_child_count():
		var rp = Vector2(randi_range(dlimits.x,dlimits.y),randi_range(dlimits.x,dlimits.y))
		if used_positions_d.has(rp) or used_positions_c.has(rp) or forbidden_positions.has(rp): continue
		else: used_positions_d.append(rp)
		
		if used_positions_d.size() > densitysprouts.get_child_count(): break
	
	var c = densitysprouts.get_children()
	for i in c:
		i.move_to(used_positions_d[c.find(i)])

func move_conjures():
	await get_tree().create_timer(0.25).timeout
	used_positions_c.clear()
	while used_positions_c.size() < conjures.get_child_count():
		var rp = Vector2(randi_range(limits.x,limits.y),randi_range(limits.x,limits.y))
		if used_positions_c.has(rp) or used_positions_d.has(rp) or forbidden_positions.has(rp): continue
		else: used_positions_c.append(rp)
		
		if used_positions_c.size() > conjures.get_child_count(): break
	
	var c = conjures.get_children()
	for i in c:
		i.move_to(used_positions_c[c.find(i)])
