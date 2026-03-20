shader_type spatial;
// blend_mix + depth_draw_never le dice a Godot que ordene estos objetos
// por distancia a la cámara automáticamente (transparent queue)
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_lambert, specular_disabled;

uniform sampler2D atlas_texture : source_color, filter_linear_mipmap;
uniform int atlas_columns = 6;
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.5;

void vertex() {
	float tree_index = INSTANCE_CUSTOM.x;
	float col_width = 1.0 / float(atlas_columns);
	UV.x = UV.x * col_width + tree_index * col_width;
}

void fragment() {
	vec4 color = texture(atlas_texture, UV);
	// En lugar de discard usamos alpha scissor suave
	// para que Godot pueda ordenar correctamente por profundidad
	float alpha = color.a;
	alpha = smoothstep(alpha_threshold - 0.05, alpha_threshold + 0.05, alpha);
	if (alpha < 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = alpha;
}
