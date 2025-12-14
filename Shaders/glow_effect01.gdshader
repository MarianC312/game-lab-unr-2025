shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disabled, cull_disabled;

uniform float highlight_alpha : hint_range(0.0, 1.0) = 0.4;
uniform vec4 color : source_color = vec4(1.0, 1.0, 0.2, 1.0);
uniform float glow_strength = 2.0;
uniform float push = 0.015;

void fragment() {
    ALBEDO = color.rgb;
	EMISSION = color.rgb * glow_strength;
	ALPHA = highlight_alpha;
}

void vertex() {
    VERTEX += NORMAL * push;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
