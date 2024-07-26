shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}


void fragment() {
	//COLOR.rgb *= circle(UV,0.2,0.001);
	COLOR.a -= circle(UV,0.2,0.001);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
