@tool
extends MultiMeshInstance3D

@export var min_scale := 0.8
@export var max_scale := 1.4
@export var area_width := 25.0   # Ancho del área donde se generan los árboles
@export var area_length := 100.0 # Largo del área
@export var density := 0.02      # Árboles por metro cuadrado
@export var terrain: MeshInstance3D

var noise := FastNoiseLite.new()

func _ready():
	if terrain == null:
		push_error("No se asignó terreno")
		return

	# Cantidad de árboles según densidad y área
	var count = int(area_width * area_length * density)
	multimesh.instance_count = count

	for i in count:
		transform = Transform3D()

		# Posición aleatoria dentro del área
		var x_pos = randf_range(-area_width/2, area_width/2)
		var z_pos = randf_range(-area_length/2, area_length/2)

		# Altura según terreno (simple, ajusta si tu terreno es más complejo)
		var y_pos = terrain.global_transform.origin.y + 6

		transform.origin = Vector3(x_pos, y_pos, z_pos)

		# Rotación aleatoria alrededor del eje Y
		# transform.basis = Basis(Vector3.UP, randf() * TAU)

		# Escala aleatoria
		var _scale = randf_range(min_scale, max_scale)
		transform.basis = transform.basis.scaled(Vector3.ONE * _scale)

		# Aplicamos la transform
		multimesh.set_instance_transform(i, transform)

		# Variante del atlas (0 a 5 si son 6 imágenes)
		var variant = randi() % 6
		multimesh.set_instance_custom_data(i, Color(variant, 0, 0))
