shader_type spatial;
render_mode specular_schlick_ggx, diffuse_burley, cull_disabled;

uniform sampler2D textur : source_color, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO *= texture(textur,UV).rgb;
	ALPHA *= ALBEDO.r - 0.5;
	EMISSION *= ALBEDO;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
