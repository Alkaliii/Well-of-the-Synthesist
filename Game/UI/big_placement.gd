extends HBoxContainer

@onready var place = $place
@onready var element_name = $FirstSecThird/HBoxContainer/ElementName
@onready var player = $FirstSecThird/HBoxContainer/player
@onready var isotopic_tier = $FirstSecThird/IsotopicTier
@onready var isotope_sum = $FirstSecThird/IsotopeSum


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_details(rank : int,d := {}):
	place.text = str(rank + 1,".")
	var c = Color.BLACK.to_html()
	if d.has("mixture"): element_name.text = str("[wave]",d["mixture"].values()[0])
	if d.has("player_name"): player.text = str("[color=",c,"][pulse][b]",d["player_name"].values()[0])
	if d.has("score"): isotopic_tier.text = str("efficacy: ",snapped(float(d["score"].values()[0]),0.01))
	if d.has("sum"): isotope_sum.text = str(d["sum"].values()[0])
