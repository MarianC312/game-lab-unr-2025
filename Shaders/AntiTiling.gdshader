shader_type spatial;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float tiling_small = 6.0;
uniform float tiling_large = 2.0;
uniform float mix_factor = 0.45;
uniform float roughness_val = 0.9;

void fragment() {
    vec4 small = texture(texture_albedo, UV * tiling_small);
    vec4 large = texture(texture_albedo, UV * tiling_large + vec2(0.3, 0.7));
    
    vec4 albedo = mix(small, large, mix_factor);
    
    ALBEDO = albedo.rgb;
    ROUGHNESS = roughness_val;
    METALLIC = 0.0;
}