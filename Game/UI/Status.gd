extends HBoxContainer

@onready var move_count = $MoveCount
@onready var volatility = $VBoxContainer/Volatility
@onready var total_fusion_count = $VBoxContainer/TotalFusionCount

# Called when the node enters the scene tree for the first time.
func _ready():
	move_count.text = str("[wave]",100)
	volatility.text = str("volatility : 0")
	total_fusion_count.text = str("impurities : 0")
	Global.open_cauldron.connect(s_on_c)

func s_on_c(s : bool):
	subtle(s)


var oldv := 0
var oldmc := 100
var oldtfc := 0

func _process(_delta):
	if oldv != Global.volatility:
		volatility.text = str("volatility : ",snapped(Global.volatility,0.01))
		oldv = Global.volatility
	
	if oldmc != Global.move_count:
		move_count.text = str("[wave]",Global.move_count)
		oldmc = Global.move_count
	
	if oldtfc != Global.total_fusion_count:
		total_fusion_count.text = str("impurities : ",Global.total_fusion_count)
		oldtfc = Global.total_fusion_count 

var tws : Tween
func subtle(s : bool):
	if get_tree() == null: return
	if tws: tws.kill()
	tws = create_tween()
	match s:
		true: #ON
			tws.tween_property(self,"modulate:a",0.2,0.25).set_ease(Tween.EASE_IN_OUT)
		false:
			tws.tween_property(self,"modulate:a",1,0.25).set_ease(Tween.EASE_IN_OUT)
