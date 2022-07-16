shader_type canvas_item;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	COLOR = mix(col, vec4(1.0, 1.0, 1.0, col.a), 0.0);
}