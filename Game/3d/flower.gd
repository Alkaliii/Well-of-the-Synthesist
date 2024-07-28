extends AnimatableBody3D

enum ft {
	DENSITY_SPROUT,
	CONJURE_FLOWR,
}
@export var plant_type : ft = ft.DENSITY_SPROUT
@onready var range_indicator = $range_indicator

var tile_size = 1.6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var rtw : Tween
func range_state(s : bool):
	if rtw: rtw.kill()
	rtw = create_tween()
	match s:
		true:
			rtw.tween_property(range_indicator.material_override,"shader_parameter/Strength",1.5,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		false:
			rtw.tween_property(range_indicator.material_override,"shader_parameter/Strength",30,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

@onready var p_sprite = $pSprite
const dss = [Rect2(192,0,96,96),Rect2(288,0,96,192)]
const cfs = [Rect2(96,96,96,96),Rect2(96,0,96,96)]
func set_flower():
	var rs = randf_range(0.9,1.1)
	p_sprite.scale = Vector3(rs,rs,rs)
	match plant_type:
		ft.DENSITY_SPROUT:
			p_sprite.texture.region = dss.pick_random()
		ft.CONJURE_FLOWR:
			p_sprite.texture.region = cfs.pick_random()

func move_to(gridpos : Vector2):
	var newpos = Vector3(gridpos.x,0,gridpos.y) * tile_size
	newpos.snapped(Vector3.ONE * tile_size)
	newpos += Vector3.ONE * (tile_size/2)
	newpos.y = position.y
	var tw = create_tween()
	tw.tween_property(self,"scale",Vector3.ZERO,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.parallel().tween_property(range_indicator.material_override,"shader_parameter/alpha",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(p_sprite.material_override,"shader_parameter/alpha",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self,"position",newpos,0.15).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_callback(set_flower)
	tw.tween_property(self,"scale",Vector3.ONE,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(range_indicator.material_override,"shader_parameter/alpha",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(p_sprite.material_override,"shader_parameter/alpha",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
