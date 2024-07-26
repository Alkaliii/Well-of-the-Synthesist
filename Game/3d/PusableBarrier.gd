extends Area3D

enum mb {
	MIRRORX,
	MIRRORZ,
}
@export var behaviour := mb.MIRRORX

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	match behaviour:
		mb.MIRRORX:
			if body.has_method("flipx"):
				body.flipx()
			#body.position.x = -body.position.x
		mb.MIRRORZ:
			if body.has_method("flipz"):
				body.flipz()
			#body.position.z = -body.position.z
