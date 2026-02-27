shader_type spatial;

render_mode cull_disabled, depth_draw_opaque;

uniform float wind_strength : hint_range(0.0, 1.0) = 0.05;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wind_scale : hint_range(0.1, 5.0) = 3.5;

uniform vec3 bottom_color : source_color = vec3(0.1, 0.4, 0.1);
uniform vec3 top_color : source_color = vec3(0.3, 0.8, 0.3);

float random(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {

    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Invertimos UV por si está al revés
    float height_factor = 1.0 - UV.y;

    // Random único por blade basado en posición
    float blade_random = random(world_pos.xz);

    // Variación de velocidad por blade
    float local_speed = wind_speed + blade_random * 1.5;

    // Variación de fase
    float phase_offset = blade_random * 10.0;

    float wind = sin(
        TIME * local_speed +
        (world_pos.x + world_pos.z) * wind_scale +
        phase_offset
    );

    float displacement = wind * wind_strength * height_factor;

    VERTEX.x += displacement;
}

void fragment() {
    ALBEDO = mix(bottom_color, top_color, UV.y);
}