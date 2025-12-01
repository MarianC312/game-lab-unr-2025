shader_type spatial;

uniform vec3 pointer_position = vec3(0.0);
uniform float pointer_base_size = 0.1;
uniform float pointer_strength = 3.0;
uniform float fade = 1.0; // Para animar aparición/desaparición

uniform vec4 pointer_color : source_color = vec4(1.0, 0.2, 0.1, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.6, 0.2, 1.0);

void fragment() {
    float d = distance(VERTEX, pointer_position);

    // ---- PULSACIÓN ----
    float pulse = (sin(TIME * 6.0) * 0.5 + 0.5) * 0.05;
    float size = pointer_base_size + pulse;

    // ---- MARCADOR CENTRAL ----
    float marker = smoothstep(size, size * 0.5, d);

    // ---- HALO EXTERNO ----
    float halo = smoothstep(size * 3.0, size * 1.2, d);
    halo *= (sin(TIME * 4.0 + d * 25.0) * 0.5 + 0.5);

    // ---- FADE GLOBAL ----
    marker *= fade;
    halo *= fade;

    // ---- COLOR BASE ----
    vec3 base_color = vec3(0.8);

    // Color final del material
    ALBEDO = mix(pointer_color.rgb, base_color, marker);

    // ---- BRILLO (EMISIÓN) ----
    EMISSION = glow_color.rgb * halo * pointer_strength;
}
