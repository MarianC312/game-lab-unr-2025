shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never;

uniform vec4 outline_color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float outline_width : hint_range(0.0, 0.1) = 0.15;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;

void vertex() {
    vec3 normal = normalize(NORMAL);
    float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;
    VERTEX += normal * outline_width * pulse;
}

void fragment() {
    float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;
    ALBEDO = outline_color.rgb;
    ALPHA = pulse;
}