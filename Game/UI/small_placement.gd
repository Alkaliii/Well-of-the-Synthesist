extends HBoxContainer

@onready var place = $place
@onready var element_name = $NotFirstSecThird/HBoxContainer/ElementName
@onready var player = $NotFirstSecThird/HBoxContainer/player
@onready var isotope_sum = $NotFirstSecThird/IsotopeSum

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_details(rank : int,d := {}):
	place.text = str(rank + 1,".")
	var c = Color.BLACK.to_html()
	if d.has("mixture"): element_name.text = str("[wave]",d["mixture"].values()[0])
	if d.has("player_name"): player.text = str("[color=",c,"][pulse][b]",d["player_name"].values()[0])
	if d.has("sum"): isotope_sum.text = str(d["sum"].values()[0])
