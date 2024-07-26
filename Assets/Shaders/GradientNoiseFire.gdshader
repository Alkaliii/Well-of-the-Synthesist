shader_type spatial;
render_mode unshaded, depth_prepass_alpha;

uniform sampler2D tex: source_color;
uniform sampler2D mask_noise : hint_default_white;
uniform sampler2D mask : hint_default_white;
uniform float alpha: hint_range(0.0, 1.0, 0.1) = 1.0;

uniform vec2 speed = vec2(1,1);
uniform vec2 vspeed = vec2(1,1);
uniform vec2 vminmax = vec2(1,1);
uniform float vstr: hint_range(0.0, 1.0, 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
	vec4 mak0 = texture(mask_noise,UV + (TIME * vspeed));
	VERTEX.xz *= (mak0.r * vstr) + vminmax.x;
}

vec4 blend(vec4 base, vec4 blend){
	return base + blend;
}


void fragment() {
	vec4 alb0 = texture(tex,UV);
	vec4 mak0 = texture(mask_noise,UV + (TIME * speed));
	vec4 mak1 = texture(mask,UV);
	vec4 makf = blend(mak0,mak1);
	
	ALBEDO = alb0.rgb;
	ALPHA = (alb0.a * makf.r) * alpha;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
