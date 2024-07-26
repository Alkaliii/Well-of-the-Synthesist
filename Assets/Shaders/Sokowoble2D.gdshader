shader_type canvas_item;

uniform float normal_offset : hint_range(0, 2, .1) = 1.5;
uniform float time_influence : hint_range(0, 50) = 3;
uniform float y_div : hint_range(0, 10, .1) = 2.87;
uniform vec2 offset_time =  vec2(1.0,1.0);

void vertex() {
	VERTEX.x += sin(VERTEX.y * y_div + round((TIME+offset_time.x) * time_influence)) * normal_offset;
	VERTEX.y += sin(VERTEX.x * y_div + round((TIME+offset_time.y) * time_influence)) * normal_offset;
}