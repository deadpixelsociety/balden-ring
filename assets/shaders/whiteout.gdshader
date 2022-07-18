shader_type canvas_item;

uniform vec4 color: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float amount: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	COLOR = mix(col, vec4(color.rgb, col.a), amount);
}