shader_type canvas_item;

//#define t TIME
#define iResolution 1.0/SCREEN_PIXEL_SIZE

uniform float t : hint_range(3.14, 6.28, 0.1);
uniform sampler2D alpha_mask : hint_default_white;
uniform float res_x = 1152;
uniform float res_y = 648;

void fragment(){
	vec3 c;
	float l,z = t;
	for(int i = 0;i < 3; i++) {
		vec2 uv,p = UV;
		float ratio = res_x / res_y;
		uv = p;
		p -= 0.5;
		//p.x *= UV.x/UV.y;
		p = p * vec2(ratio, 1.0);
		z += .07;
		l = length(p);
		uv += p/l * (sin( z * 1.0) + 1.) * abs(sin( l * 9. - z - z));
		c[i] = .01/length(mod(uv,1.)-.5);
	}
	COLOR*=vec4(c/l,t);
	COLOR.a = COLOR.r * COLOR.a * texture(alpha_mask,UV).r;
}