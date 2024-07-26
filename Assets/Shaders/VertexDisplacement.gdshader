shader_type spatial;

uniform sampler2D noise_tex : hint_default_white;
uniform sampler2D noise_texB : hint_default_white;
uniform vec2 speed = vec2(1,1);
uniform float str : hint_range(0.0, 3.0, 0.1) = 0.5;
uniform float ctrl : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform vec2 time_offset = vec2(1,1);

void vertex() {
	// Called for every vertex the material is visible on.
	vec2 pos = VERTEX.xz / 2.0 + 0.5;
	float dispA = texture(noise_tex, pos + (TIME + time_offset.x) * speed).r * str;
	float dispB = texture(noise_tex, pos + (TIME + time_offset.y) * speed).r * str;
	VERTEX.x /= dispA + ctrl;
	VERTEX.z /= dispB + ctrl;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
