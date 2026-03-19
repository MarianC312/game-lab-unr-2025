extends WorldEnvironment

@export var offset := 0.0
@export var offvel := 0.01
var noise_instance: FastNoiseLite

func _ready() -> void:
	var sky_material = environment.sky.sky_material as PhysicalSkyMaterial
	if sky_material and sky_material.night_sky:
		var noise_tex = sky_material.night_sky as NoiseTexture2D
		if noise_tex:
			noise_instance = noise_tex.noise.duplicate()
			noise_tex.noise = noise_instance

func _process(delta: float) -> void:
	offset += delta * offvel  # velocidad del movimiento, ajustá este valor
	
	var sky_material = environment.sky.sky_material as PhysicalSkyMaterial
	if sky_material and sky_material.night_sky:
		var noise_tex = sky_material.night_sky as NoiseTexture2D
		if noise_tex and noise_tex.noise:
			noise_tex.noise.offset = Vector3(-offset, 0.0, -offset)
