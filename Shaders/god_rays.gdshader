shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 color : source_color = vec4(1.0, 0.95, 0.8, 1.0);
uniform float density : hint_range(0.0, 1.0) = 0.045;
uniform float noise_scale = 1.0;
uniform float speed = -1.25;
uniform float fade_height = 1.5;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float n = fract(
        sin(dot(world_pos.xz * noise_scale + TIME * speed,
        vec2(12.9898,78.233))) * 43758.5453
    );

    float height_fade = clamp(
        (fade_height - world_pos.y) / fade_height,
        0.0, 1.0
    );

    float alpha = n * density * height_fade;

    ALBEDO = color.rgb;
    EMISSION = color.rgb * 0.5;
    ALPHA = alpha;
}
