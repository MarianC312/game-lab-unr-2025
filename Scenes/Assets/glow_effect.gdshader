shader_type spatial;
render_mode unshaded, depth_draw_always; // clave: siempre se dibuja

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.3, 1.0);

void fragment() {
    ALBEDO = glow_color.rgb;
    EMISSION = glow_color.rgb * 2.0;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
