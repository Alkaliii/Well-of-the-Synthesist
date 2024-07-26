shader_type spatial;

uniform sampler2D TEXTURE: source_color;
uniform float inv_proximity_fade_distance = 1.0;
uniform float proximity_fade_distance = 1.0;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform bool y_billboard = false; // Enables Y-Billboarding when true
uniform float df_unshaded : hint_range(0.0, 2.0, 0.001) = 1.0;
uniform float twk_shaded : hint_range(0.0, 1.0, 0.001) = 0.4;

uniform sampler2D flowMap;
uniform sampler2D mask_tex : hint_default_white;
uniform vec2 direction = vec2(1.0, 1.0);
uniform float strength = 0.3;

varying float LIFETIME;
varying float INDEX;

void vertex() {
	LIFETIME = INSTANCE_CUSTOM.y;
	INDEX = float(INSTANCE_ID);

	if (y_billboard == true) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	}
	else {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	vec4 noise_sample = texture(flowMap, UV + (TIME * direction)); // Sample the noise vec2(UV.x + (TIME * direction.x * -1.0), UV.y + (TIME * direction.y))
	vec4 offset = noise_sample * strength; // Apply strength scalar for a UV offset 
	vec4 fogtex = texture(TEXTURE, UV + offset.xy); // Sample the texture using the UV offset
	fogtex.a *= noise_sample.r;
	
	float mask = texture(mask_tex,UV).r;
	ALBEDO = fogtex.rgb * COLOR.rgb;
	ALPHA = clamp((fogtex.a * COLOR.a) * mask,0,1);
	
	float depth_tex = textureLod(depth_texture,SCREEN_UV,0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex,1.0);
	world_pos.xyz/=world_pos.w;
	ALPHA *= clamp(smoothstep(world_pos.z+inv_proximity_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);
	ALPHA *= clamp(1.0-smoothstep(world_pos.z+proximity_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);
}

//void light() {
	//float sf = ATTENUATION;
	//if (sf < 1.0) {
		//DIFFUSE_LIGHT += (max(dot(VIEW, LIGHT),0.0) * ATTENUATION + twk_shaded) * (LIGHT_COLOR / PI);// * ALBEDO;// * LIGHT_COLOR;
	//}
	//else {
		//DIFFUSE_LIGHT = vec3(df_unshaded) * (LIGHT_COLOR / PI);
	//}
//}
