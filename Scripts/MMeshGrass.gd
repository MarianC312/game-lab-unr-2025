@tool
extends MultiMeshInstance3D

@export_group("Distribución")
@export var instance_count: int = 100:
	set(v):
		instance_count = v
		if Engine.is_editor_hint(): _distribute()

@export var area_center: Vector3 = Vector3(0, 0, 0):
	set(v):
		area_center = v
		if Engine.is_editor_hint(): _distribute()

@export var area_size: Vector3 = Vector3(100.0, 0.0, 100.0):
	set(v):
		area_size = v
		if Engine.is_editor_hint(): _distribute()

@export_group("Escala")
@export var min_scale: float = 0.3:
	set(v):
		min_scale = v
		if Engine.is_editor_hint(): _distribute()

@export var max_scale: float = 0.7:
	set(v):
		max_scale = v
		if Engine.is_editor_hint(): _distribute()

@export_group("Altura")
@export var y_offset: float = 1.0:
	set(v):
		y_offset = v
		if Engine.is_editor_hint(): _distribute()

@export var y_random_range: float = 0.0:
	set(v):
		y_random_range = v
		if Engine.is_editor_hint(): _distribute()

@export_group("Zona de exclusión")
@export var exclusion_radius: float = 0.0:
	set(v):
		exclusion_radius = v
		if Engine.is_editor_hint(): _distribute()

@export var exclusion_center: Vector2 = Vector2(0, 0):
	set(v):
		exclusion_center = v
		if Engine.is_editor_hint(): _distribute()

@export_group("Semilla")
@export var use_seed: bool = true:
	set(v):
		use_seed = v
		if Engine.is_editor_hint(): _distribute()

@export var random_seed: int = 43:
	set(v):
		random_seed = v
		if Engine.is_editor_hint(): _distribute()

@export_group("Herramientas")
@export var regenerate: bool = false:
	set(v):
		if v: _distribute()
		regenerate = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		_distribute()


func _distribute() -> void:
	if not multimesh:
		push_error("MultiMeshDistributor: asigná un MultiMesh primero.")
		return

	var rng := RandomNumberGenerator.new()
	if use_seed:
		rng.seed = random_seed

	var transforms: Array[Transform3D] = []
	var attempts := 0
	var max_attempts := instance_count * 20

	while transforms.size() < instance_count and attempts < max_attempts:
		attempts += 1

		var x := area_center.x + rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z := area_center.z + rng.randf_range(-area_size.z * 0.5, area_size.z * 0.5)

		if exclusion_radius > 0.0:
			var dist := Vector2(x - exclusion_center.x, z - exclusion_center.y).length()
			if dist < exclusion_radius:
				continue

		var y := y_offset + rng.randf_range(-y_random_range * 0.5, y_random_range * 0.5)
		var s := rng.randf_range(min_scale, max_scale)
		var rot_y := rng.randf_range(0.0, TAU)

		var t := Transform3D()
		t = t.rotated(Vector3.UP, rot_y)
		t = t.scaled(Vector3(s, s, s))
		t.origin = Vector3(x, y, z)
		transforms.append(t)

	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = transforms.size()

	for i in transforms.size():
		multimesh.set_instance_transform(i, transforms[i])

	if transforms.size() < instance_count:
		push_warning("MultiMeshDistributor: solo se colocaron %d/%d instancias (zona de exclusión muy grande?)." % [transforms.size(), instance_count])
