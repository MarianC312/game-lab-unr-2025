shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix;

uniform vec4 color : source_color = vec4(1.0, 0.35, 0.18, 0.015);
uniform float density : hint_range(0.0, 1.0) = 0.25;
uniform float noise_scale = 1.0;
uniform float speed = 3.25;
uniform float fade_height = 2.5;

varying vec3 world_pos;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f); // smoothstep
    return mix(
        mix(hash(i), hash(i + vec2(1,0)), u.x),
        mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), u.x),
        u.y
    );
}

float fbm(vec2 p) {
    float v = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 4; i++) {
        v += amp * noise(p);
        p = p * 2.1 + vec2(1.7, 9.2); // offset para evitar simetría
        amp *= 0.5;
    }
    return v;
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 uv = world_pos.xz * noise_scale;

    // Dos capas moviendose en direcciones distintas
    float n1 = fbm(uv + TIME * speed * 0.3 * vec2(1.0, 0.7));
    float n2 = fbm(uv + TIME * speed * 0.2 * vec2(-0.6, 1.0));
    float n = mix(n1, n2, 0.5);

    float height_fade = clamp(
        (fade_height - world_pos.y) / fade_height,
        0.0, 1.0
    );

    float alpha = n * density * height_fade;
    ALBEDO = color.rgb;
    ALPHA = alpha;
}