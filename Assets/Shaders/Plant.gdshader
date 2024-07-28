shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color;
uniform vec4 tint : source_color = vec4((1.0));

//
uniform float normal_offset : hint_range(0, 2, .01) = 1.5;
uniform float time_influence : hint_range(0, 50) = 3;
uniform float y_div : hint_range(0, 10, .1) = 2.87;
uniform vec2 offset_time =  vec2(1.0,1.0);
uniform float alpha: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float offsetuv: hint_range(0.0, 1.0, 0.1) = 0.0;

void vertex() {
	VERTEX.x += sin(VERTEX.y * y_div + round((TIME+offset_time.x) * time_influence)) * normal_offset;
	VERTEX.z += sin(VERTEX.x * y_div + round((TIME+offset_time.y) * time_influence)) * normal_offset;
}

void fragment() {
	vec4 t = texture(tex,UV);
	ALBEDO = t.rgb * tint.rgb;
	ALPHA = t.a * alpha;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
