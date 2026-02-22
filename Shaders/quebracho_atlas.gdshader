shader_type spatial;
render_mode cull_disabled;

uniform sampler2D atlas_texture;
uniform float total_variants = 6.0;

uniform float wind_strength = 0.2;
uniform float wind_speed = 1.5;

// Variable que va del vertex al fragment
varying float v_variant;

void vertex() {
    // Factor de altura: 0 = base, 1 = punta
    float height_factor = pow(UV.y, 1.0); // suaviza la transición desde tronco a hojas

    // Viento en la copa (solo Z)
	if (VERTEX.x > 5.0){
		float wind = sin(TIME * wind_speed + VERTEX.x * 0.15) * wind_strength;
    	VERTEX.z += wind * height_factor;
	}
    // Variante del atlas
    v_variant = INSTANCE_CUSTOM.x;
}

void fragment() {
    vec2 tex_uv = UV;  // Crear una copia para modificar
    float variant = v_variant; // copiar la variante a una variable local

    tex_uv.x = (tex_uv.x / total_variants) + (variant / total_variants);

    vec4 tex = texture(atlas_texture, tex_uv);

    // --- iluminación simulada ---
    vec3 light_dir = normalize(vec3(-1.0, -1.0, 1.0)); // dirección del sol
    vec3 normal = vec3(0.0, 0.0, 1.0); // normal del quad
    float light_factor = max(dot(normal, -light_dir), 0.2);
    ALBEDO = tex.rgb * light_factor;

    ALPHA = tex.a;
    if (ALPHA < 0.1) discard;
}