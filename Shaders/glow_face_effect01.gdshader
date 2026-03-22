shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_add;

uniform vec4 color : source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float fresnel_power : hint_range(1.0, 8.0) = 1.8;
uniform float intensity : hint_range(0.0, 5.0) = 2.8;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;

void fragment() {
    vec3 normal = normalize(NORMAL);
    vec3 view = normalize(VIEW);

    float fresnel = pow(1.0 - abs(dot(normal, view)), fresnel_power);
    float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8;

    float alpha = clamp(fresnel * intensity * pulse, 0.0, 1.0);

    ALBEDO = color.rgb * intensity * pulse;
    ALPHA = alpha;
}