shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix;

uniform vec4 color : source_color = vec4(1.0, 0.35, 0.18, 0.015);
uniform float density : hint_range(0.0, 1.0) = 0.25;
uniform float noise_scale = 1.0;
uniform float speed = 3.25;
uniform float fade_height = 2.5;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
        vec2 uv = world_pos.xz * noise_scale;

    // Movimiento en espiral en lugar de lineal
    float t = TIME * speed * 0.1;
    vec2 drift = vec2(sin(t) * 0.8 + t, cos(t * 0.7) * 0.6 + t * 0.5);

    float n = fract(
        sin(dot(uv + drift, vec2(122.9898, 78.233))) * 43758.5453
    );

    float height_fade = clamp(
        (fade_height - world_pos.y) / fade_height,
        0.0, 1.0
    );

    ALBEDO = color.rgb;
    ALPHA = n * density * height_fade;
}