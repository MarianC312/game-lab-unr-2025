shader_type spatial;

uniform sampler2D noise_texture : hint_default_black;
uniform float bump_strength : hint_range(0.0, 2.0) = 0.3;
uniform vec4 color_a : source_color = vec4(0.16, 0.07, 0.02, 1.0);
uniform vec4 color_b : source_color = vec4(0.35, 0.18, 0.05, 1.0);

void vertex() {
    float noise = texture(noise_texture, UV).r;
    VERTEX.y += noise * bump_strength;
}

void fragment() {
    float noise = texture(noise_texture, UV).r;
    ALBEDO = mix(color_a.rgb, color_b.rgb, noise);
    ROUGHNESS = 0.95;
    METALLIC = 0.0;
}