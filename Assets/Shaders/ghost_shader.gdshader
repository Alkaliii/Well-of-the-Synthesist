shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color;
uniform sampler2D colorgrad : hint_default_white;
//uniform vec4 color : source_color = vec4(1.0);

uniform float normal_offset : hint_range(0, 2, .1) = 1.5;
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
	vec4 c = texture(colorgrad,UV + vec2(0.0,offsetuv));
	ALBEDO = t.rgb;
	ALPHA *= t.a;
	ALBEDO *= c.rgb * (1.0 - UV.y);
	ALPHA *= c.a * alpha;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
