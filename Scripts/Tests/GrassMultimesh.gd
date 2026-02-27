extends MultiMeshInstance3D

@export var amount := 1000
@export var area_size := 10.0

func _ready():
	randomize()
	
	multimesh.instance_count = amount
	
	for i in amount:
		var transform = Transform3D()
		
		var x = randf_range(-area_size, area_size)
		var z = randf_range(-area_size, area_size)
		
		transform.origin = Vector3(x, 0, z)
		
		# Rotación aleatoria
		transform.basis = Basis(Vector3.UP, randf() * TAU)
		
		# Escala aleatoria (altura distinta)
		var scale = randf_range(0.8, 1.3)
		transform.basis = transform.basis.scaled(Vector3(1, scale, 1))
		
		multimesh.set_instance_transform(i, transform)
