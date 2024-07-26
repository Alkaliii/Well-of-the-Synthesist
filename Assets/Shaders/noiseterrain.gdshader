shader_type spatial;
render_mode specular_toon, diffuse_toon;

uniform vec4 tcolor : source_color = vec4(1.0);
uniform float strength : hint_range(-10.0, 10.0, 0.1) = 1.0;
uniform vec2 tspeed = vec2(1.0);
uniform sampler2D noise_tex : source_color;
uniform sampler2D noise_mask : source_color;

vec4 blend(vec4 base, vec4 blend){
	return base * blend;
}

void vertex() {
	// Called for every vertex the material is visible on.
	float offset = blend(texture(noise_tex,UV),texture(noise_mask,UV)).r;
	float t_offset = blend(texture(noise_tex,UV + (TIME * tspeed)),texture(noise_mask,UV + (TIME * tspeed))).r;
	VERTEX.y += (offset * strength) + t_offset;
}

void fragment() {
	METALLIC = 0.0;
	ROUGHNESS = 0.01;
	vec4 color = blend(texture(noise_tex,UV),texture(noise_mask,UV));
	ALBEDO += color.rgb;
	ALBEDO *= tcolor.rgb;
}

//void light() {
	//DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR;
//}
