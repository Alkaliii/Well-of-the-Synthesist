shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_linear_mipmap;
uniform sampler2D eye_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 cloak_col : source_color = vec4(0.0,0.0,0.0,1.);
uniform vec4 hood_col : source_color = vec4(1.0,1.0,1.0,1.);

group_uniforms eye_A;
uniform vec4 eyeA_col : source_color = vec4(1.0);
uniform float eyeA_rot = 0.785;
uniform vec2 eyeA_scale = vec2(1.0);
uniform vec2 eyeA_translate = vec2(0.05,0.02);
group_uniforms eye_B;
uniform vec4 eyeB_col : source_color = vec4(1.0);
uniform float eyeB_rot = 2.355;
uniform vec2 eyeB_scale = vec2(1.0);
uniform vec2 eyeB_translate = vec2(-0.05,0.02);
group_uniforms eye_C;
uniform vec4 eyeC_col : source_color = vec4(1.0);
uniform float eyeC_rot = 1.57;
uniform vec2 eyeC_scale = vec2(1.0);
uniform vec2 eyeC_translate = vec2(0,0.09);

vec2 atlas(vec2 uv, vec2 size, float progress){
	progress = floor( mod(progress, (size.x * size.y)) );
	vec2 frame_size = vec2(1.0, 1.0) / vec2(size.x, size.y);
	vec2 frame = fract(uv / size) + frame_size;
	
	frame.x += ( (progress / size.x) - frame_size.x * floor(progress/size.x) * size.x ) - frame_size.x;
	frame.y += (frame_size.y * floor(progress/size.x) ) - frame_size.y ;
	
	return frame;
}

vec2 rotate(vec2 uv, vec2 pivot, float angle){
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

vec2 scale(vec2 uv, float x, float y)
{
	mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));
	
	uv -= 0.5;
	uv = uv * scale;
	uv += 0.5;
	return uv;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//total
	vec2 tUV = atlas(UV, vec2(9.0, 2.0),0.0);
	ALPHA = texture(tex,tUV).a;
	//back
	vec2 backUV = atlas(UV, vec2(9.0, 2.0),1.0);
	vec4 back = texture(tex,backUV);
	//cloak
	vec2 clkUV = atlas(UV, vec2(9.0, 2.0),2.0);
	vec4 cloak = texture(tex,clkUV) * cloak_col;
	//hood
	vec2 hUV = atlas(UV, vec2(9.0, 2.0),3.0);
	vec4 hood = texture(tex,hUV) * hood_col;
	//outlines
	vec2 otUV = atlas(UV, vec2(9.0, 2.0),4.0);
	vec4 outln = texture(tex,otUV);
	//eyes
	vec4 eyeA = texture(eye_tex,scale(rotate(UV + eyeA_translate,vec2(0.5),eyeA_rot),eyeA_scale.x,eyeA_scale.y)) * eyeA_col;
	vec4 eyeB = texture(eye_tex,scale(rotate(UV + eyeB_translate,vec2(0.5),eyeB_rot),eyeB_scale.x,eyeB_scale.y)) * eyeB_col;
	vec4 eyeC = texture(eye_tex,scale(rotate(UV + eyeC_translate,vec2(0.5),eyeC_rot),eyeC_scale.x,eyeC_scale.y)) * eyeC_col;
	
	ALBEDO = mix(mix(mix(mix(mix(mix(back,cloak,cloak.a),hood,hood.a),outln,outln.a),eyeA,eyeA.a),eyeB,eyeB.a),eyeC,eyeC.a).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
