extends Node3D

@onready var ld = $SubViewport/LD
@onready var sub_viewport = $SubViewport


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func detect_light() -> float:
	ld.global_position = global_position
	var texture = sub_viewport.get_texture()
	get_tree().get_first_node_in_group("DLT").texture = texture
	var color = get_average_color(texture)
	get_tree().get_first_node_in_group("DLC").color = color
	var lum = color.get_luminance()
	print_rich(str("[color=",color.to_html(),"]",lum))
	return lum

func get_average_color(texture: ViewportTexture) -> Color:
	var image = texture.get_image() # Get the Image of the input texture
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS) # Resize the image to one pixel
	return image.get_pixel(0, 0) # Read the color of that pixel
