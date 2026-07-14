shader_type canvas_item;

uniform sampler2D shadow_texture : filter_linear, repeat_disable;
uniform float shadow_alpha = 0.35;
uniform vec2 blur_uv = vec2(0.02, 0.02);
uniform vec2 inner_min = vec2(0.0, 0.0);
uniform vec2 inner_size = vec2(1.0, 1.0);

float get_alpha(vec2 pos) {
	vec2 uv = (pos - inner_min) / inner_size;

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return 0.0;
	}

	return texture(shadow_texture, uv).a;
}

void fragment() {
	float a = 0.0;

	a += get_alpha(UV) * 0.25;

	a += get_alpha(UV + vec2(-blur_uv.x, 0.0)) * 0.125;
	a += get_alpha(UV + vec2( blur_uv.x, 0.0)) * 0.125;
	a += get_alpha(UV + vec2(0.0, -blur_uv.y)) * 0.125;
	a += get_alpha(UV + vec2(0.0,  blur_uv.y)) * 0.125;

	a += get_alpha(UV + vec2(-blur_uv.x, -blur_uv.y)) * 0.0625;
	a += get_alpha(UV + vec2( blur_uv.x, -blur_uv.y)) * 0.0625;
	a += get_alpha(UV + vec2(-blur_uv.x,  blur_uv.y)) * 0.0625;
	a += get_alpha(UV + vec2( blur_uv.x,  blur_uv.y)) * 0.0625;

	COLOR = vec4(0.0, 0.0, 0.0, a * shadow_alpha);
}