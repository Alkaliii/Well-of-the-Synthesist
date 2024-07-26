shader_type canvas_item;

vec2 scale(vec2 uv, float x, float y)
{
	mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));
	
	uv -= 0.5;
	uv = uv * scale;
	uv += 0.5;
	return uv;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float scale_amt = sin(TIME) + 1.1;
	COLOR *= texture(TEXTURE,scale(UV,scale_amt,scale_amt));
	//COLOR *= texture(TEXTURE,UV);
}
