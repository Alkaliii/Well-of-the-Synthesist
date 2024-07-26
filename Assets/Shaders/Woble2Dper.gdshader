shader_type canvas_item;

uniform vec2 atlas_size = vec2(1,1);
uniform float atlas_pos;
uniform float alpha: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec3 colort: source_color = vec3(1.0,1.0,1.0);
uniform vec2 offset_time =  vec2(1.0,1.0);

//https://godotshaders.com/shader/wobly-2d-sokpop-based/
uniform float normal_offset : hint_range(0, 2, .1) = 1.5;
uniform float time_influence : hint_range(0, 50) = 3;
uniform float y_div : hint_range(0, 10, .1) = 2.87;

//from 2Dperspective
// Camera FOV
uniform sampler2D texture_pass_in : source_color;
uniform float fov : hint_range(1, 179) = 90;
uniform bool cull_back = true;
uniform float y_rot : hint_range(-180, 180) = 0.0;
uniform float x_rot : hint_range(-180, 180) = 0.0;
// At 0, the image retains its size when unrotated.
// At 1, the image is resized so that it can do a full
// rotation without clipping inside its rect.
uniform float inset : hint_range(-1, 1) = 0.0;
// Consider changing this to a uniform and changing it from code

varying flat vec2 o;
varying vec3 p;

vec2 atlas(vec2 uv, vec2 size, float progress){
	progress = floor( mod(progress, (size.x * size.y)) );
	vec2 frame_size = vec2(1.0, 1.0) / vec2(size.x, size.y);
	vec2 frame = fract(uv / size) + frame_size;
	
	frame.x += ( (progress / size.x) - frame_size.x * floor(progress/size.x) * size.x ) - frame_size.x;
	frame.y += (frame_size.y * floor(progress/size.x) ) - frame_size.y ;
	
	return frame;
}

void vertex() {
	VERTEX.x += sin(VERTEX.y * y_div + round((TIME+offset_time.x) * time_influence)) * normal_offset;
	VERTEX.y += sin(VERTEX.x * y_div + round((TIME+offset_time.y) * time_influence)) * normal_offset;
	
	//from 2D perspective
	float sin_b = sin(y_rot / 180.0 * PI);
	float cos_b = cos(y_rot / 180.0 * PI);
	float sin_c = sin(x_rot / 180.0 * PI);
	float cos_c = cos(x_rot / 180.0 * PI);
	
	mat3 inv_rot_mat;
	inv_rot_mat[0][0] = cos_b;
	inv_rot_mat[0][1] = 0.0;
	inv_rot_mat[0][2] = -sin_b;
	
	inv_rot_mat[1][0] = sin_b * sin_c;
	inv_rot_mat[1][1] = cos_c;
	inv_rot_mat[1][2] = cos_b * sin_c;
	
	inv_rot_mat[2][0] = sin_b * cos_c;
	inv_rot_mat[2][1] = -sin_c;
	inv_rot_mat[2][2] = cos_b * cos_c;
	
	float t = tan(fov / 360.0 * PI);
	p = inv_rot_mat * vec3((UV - 0.5), 0.5 / t);
	float v = (0.5 / t) + 0.5;
	p.xy *= v * inv_rot_mat[2].z;
	o = v * inv_rot_mat[2].xy;

	VERTEX += (UV - 0.5) / TEXTURE_PIXEL_SIZE * t * (1.0 - inset);
}

void fragment(){
	if (cull_back && p.z <= 0.0) discard;
	vec2 uv = (p.xy / p.z).xy - o;
	vec2 aUV = atlas(uv + 0.5,atlas_size,atlas_pos);
	COLOR = texture(texture_pass_in, aUV);
	COLOR.rgb *= colort;
	COLOR.a *= step(max(abs(uv.x), abs(uv.y)), 0.5) * alpha;
}