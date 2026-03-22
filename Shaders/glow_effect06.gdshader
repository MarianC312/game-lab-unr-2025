shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never, blend_add;

uniform vec4 color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float outline_width : hint_range(0.0, 0.05) = 0.015;
uniform float intensity : hint_range(0.0, 5.0) = 2.8;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;

void vertex() {
    vec4 clip_pos = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    vec3 clip_normal = normalize(
        (PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz
    );
    clip_pos.xy += clip_normal.xy * outline_width * clip_pos.w;
    POSITION = clip_pos;
}

void fragment() {
    float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8;
    ALBEDO = color.rgb * intensity * pulse;
    ALPHA = 1.0;
}