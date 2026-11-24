shader_type canvas_item;
render_mode unshaded;

varying vec4 modulate;	//github.com/godotengine/godot/issues/49781

vec4 texturePointSmooth(sampler2D my_texture, vec2 uv, vec2 pixel_size)
{
	vec2 lxy = fwidth(uv);

	vec2 uv_pixel = uv / pixel_size;
	vec2 uv_pixel_floor = round(uv_pixel) - vec2(0.5f);

	vec2 uv_dxy_pixel = uv_pixel - uv_pixel_floor;
	uv_dxy_pixel = (uv_dxy_pixel - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f);
	uv_dxy_pixel = clamp(uv_dxy_pixel, 0.0f, 1.0f);

	return texture(my_texture, (uv_pixel_floor + uv_dxy_pixel) * pixel_size);
}

void vertex()
{
	modulate = COLOR;
}

void fragment()
{
	COLOR = texturePointSmooth(TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	COLOR = modulate * COLOR;
}