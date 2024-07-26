extends PanelContainer

@export var debug := false
@export var use_tl := false
@export var use_highest_discovered_iso := false

@onready var icon = $VBoxContainer/Icon
@onready var unit_type = $VBoxContainer/UnitType
@onready var element_name = $VBoxContainer/ElementName
@onready var combination_id = $VBoxContainer/combinationid
@onready var space_b = $VBoxContainer/spaceB
@onready var iso = $VBoxContainer/iso
@onready var space_c = $VBoxContainer/spaceC
@onready var isotopic_tier = $VBoxContainer/IsotopicTier

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	if debug:
		var ran = aUnit.get_random(Vector2(0,49),Vector2(0,99))
		set_tooltip(ran)
		print(ran.get_nameg())
	else:
		hide()
		top_level = use_tl

func set_tooltip(p : aUnit):
	if p is Alloy:
		icon.texture.region = Rect2(0,0,96,96)
		unit_type.text = "alloy"
		combination_id.text = str(p.particleA + 1,"+",p.particleB + 1)
		combination_id.show()
	if p is Element:
		icon.texture.region = Rect2(96,0,96,96)
		unit_type.text = "particle"
		combination_id.hide()
	
	element_name.text = str("[wave]",p.get_nameg(true))
	
	var tier = p.tier
	if use_highest_discovered_iso and Global.tiers_availible.has(p.get_nameb()):
		var ta : PackedInt32Array = Global.tiers_availible[p.get_nameb()]
		tier = ta[ta.size() - 1]
	
	if tier != 0:
		iso.show()
		space_b.show()
		space_c.show()
		isotopic_tier.text = str("[right]",tier)
		isotopic_tier.show()
	else:
		iso.hide()
		space_b.hide()
		space_c.hide()
		isotopic_tier.hide()
	
	size.y = 0
