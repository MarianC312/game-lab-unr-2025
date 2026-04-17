shader_type sky;

uniform sampler2D noise_tex : source_color;
uniform vec2 wind_dir = vec2(0.5, 0.2);
uniform float speed = 0.008;
uniform float cloud_scale_big = 0.6;
uniform float cloud_scale_detail = 2.5;
uniform float cloud_density = 0.6;
uniform float cloud_softness = 0.4;
uniform float cloud_contrast = 2.0;
uniform vec3 sky_top : source_color = vec3(0.01, 0.02, 0.05);
uniform vec3 sky_horizon : source_color = vec3(0.15, 0.2, 0.3);
uniform vec3 cloud_color : source_color = vec3(0.8, 0.85, 0.9);
uniform float stars_intensity = 0.6;
uniform float stars_density = 0.015;
uniform float stars_twinkle_speed = 2.0;
uniform float stars_twinkle_strength = 0.3;
uniform float stars_twinkle_ratio = 0.3; 
uniform float star_size_min = 0.01;
uniform float star_size_max = 0.03;
uniform float sun_size = 0.02;
uniform float sun_softness = 0.01;
uniform float sun_intensity = 5.0;
uniform vec3 sun_color : source_color = vec3(1.0, 0.95, 0.8);

void sky() {
	float t = TIME * speed;

	// UVs esféricos continuos — sin costura
	vec3 dir = normalize(EYEDIR);
	vec2 uv = vec2(
	    atan(dir.z, dir.x) / (2.0 * PI) + 0.5,
	    asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5
	);

	// -------- NUBES --------
	vec2 uv_big    = fract(uv * cloud_scale_big    + wind_dir * t);
	vec2 uv_detail = fract(uv * cloud_scale_detail + wind_dir * t * 1.5 + vec2(4.2));

	float base   = texture(noise_tex, uv_big).r;
	float detail = texture(noise_tex, uv_detail).r;

	float clouds = base * 0.8 + detail * 0.4;
	clouds = pow(clouds, cloud_contrast);
	clouds = smoothstep(cloud_softness, 1.0, clouds);
	clouds *= cloud_density;

	// -------- GRADIENTE --------
	// Usamos dir.y directo (más correcto que SKY_COORDS.y para el gradiente)
	float h = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);
	vec3 sky_grad = mix(sky_horizon, sky_top, pow(h, 1.8));
	vec3 color = mix(sky_grad, cloud_color, clouds);

	// -------- ESTRELLAS --------
	vec2 star_uv = uv * 40.0;
	vec2 cell  = floor(star_uv);
	vec2 local = fract(star_uv);

	float rnd = fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
	vec2 star_pos = vec2(fract(rnd * 23.3), fract(rnd * 91.7));
	float d = length(local - star_pos);

	float size_rnd = pow(rnd, 3.0); // bias hacia estrellas chicas
	float star_size = mix(star_size_min, star_size_max, size_rnd);

	float star = smoothstep(star_size, 0.0, d);
	star *= step(1.0 - stars_density, rnd);
	star *= smoothstep(0.0, 0.4, dir.y); // fade horizonte con dir.y

	float dynamic_rnd = fract(rnd + TIME * 0.05);
	float twinkle_mask = step(1.0 - stars_twinkle_ratio, dynamic_rnd);

	float twinkle = sin(TIME * stars_twinkle_speed + rnd * 6.2831);
	twinkle = 0.5 + 0.5 * twinkle;

	float final_twinkle = mix(1.0, twinkle, stars_twinkle_strength * twinkle_mask);

	star *= final_twinkle;

	color += star * stars_intensity;

	// -------- SOL --------

	// dirección del sol (luz principal)
	vec3 sun_dir = normalize(LIGHT0_DIRECTION);

	// ángulo entre vista y sol
	float sun_dot = dot(dir, sun_dir);

	// disco del sol
	float sun_disc = smoothstep(1.0 - sun_size, 1.0 - sun_size + sun_softness, sun_dot);

	// opcional: núcleo más fuerte
	float sun_core = smoothstep(1.0 - sun_size * 0.5, 1.0, sun_dot);

	// combinar
	float sun = max(sun_disc, sun_core);

	// agregar al color
	color += sun * sun_color * sun_intensity;

	COLOR = color;
}