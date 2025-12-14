shader_type spatial;
render_mode unshaded, cull_disabled;


uniform float highlight_alpha : hint_range(0.0, 1.0) = 0.4;
uniform vec4 color : source_color = vec4(1.0, 1.0, 0.2, 1.0);
uniform float glow_strength = 2.0;
uniform float push = 0.015;

void fragment() {
	float noise = fract(
	    sin(dot(SCREEN_UV, vec2(12.9898, 78.233))) * 43758.5453
	);

	if (noise > highlight_alpha) {
	    discard;
	}
	ALBEDO = color.rgb;
	EMISSION = color.rgb * glow_strength;
	ALPHA = 1.0;
}

void vertex() {
    VERTEX += NORMAL * push;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
