extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	resized.connect(center_cg)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@onready var cauldron_cg = $CauldronCG
func center_cg():
	cauldron_cg.position.x = size.x / 2
