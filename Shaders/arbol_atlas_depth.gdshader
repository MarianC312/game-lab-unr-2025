// Depth prepass - solo escribe al depth buffer, no dibuja color
shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, unshaded, shadows_disabled;

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
	if (color.a < alpha_threshold) discard;
	// No escribimos ALBEDO - este pass solo importa el depth
	ALBEDO = vec3(0.0);
	ALPHA = 0.0;
}
