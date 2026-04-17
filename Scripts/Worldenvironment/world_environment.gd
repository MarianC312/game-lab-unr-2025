extends WorldEnvironment

@export var offset := 0.0
@export var offvel := 0.01

# frecuencia de actualización (menos = más liviano)
@export var update_interval := 0.125

var noise_instance: FastNoiseLite
var noise_tex: NoiseTexture2D

var _accum := 0.0

func _ready() -> void:
	var sky_material = environment.sky.sky_material as PhysicalSkyMaterial
	
	if sky_material and sky_material.night_sky:
		noise_tex = sky_material.night_sky as NoiseTexture2D
		
		if noise_tex:
			noise_instance = noise_tex.noise.duplicate()
			noise_tex.noise = noise_instance


func _process(delta: float) -> void:
	offset += delta * offvel
	_accum += delta
	
	if Engine.get_process_frames() % 20 != 0:
		return
	
	print("frame:", Engine.get_process_frames())
	
	# solo actualiza cada X tiempo (ej: 10 veces por segundo)
	if _accum < update_interval:
		return
	
	_accum = 0.0
	
	if noise_instance:
		noise_instance.offset = Vector3(-offset, 0.0, -offset)
